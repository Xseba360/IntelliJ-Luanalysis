import de.undercouch.gradle.tasks.download.Download
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

fun properties(key: String) = project.findProperty(key).toString()

plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.7.20"

    id("org.jetbrains.intellij") version "1.9.0"

    id("org.jetbrains.changelog") version "1.3.1"

    id("de.undercouch.download") version "5.2.1"
}

group = properties("pluginGroup")
version = properties("pluginVersion")

repositories {
    mavenCentral()
    jcenter()
}

dependencies {
    implementation(fileTree("libs") {
        include("*.jar")
    })

    implementation("org.jetbrains:markdown:0.3.1")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

intellij {
    pluginName.set(properties("pluginName"))
    version.set(properties("platformVersion"))

    downloadSources.set(properties("platformDownloadSources").toBoolean())
    updateSinceUntilBuild.set(true)

    plugins.set(
        properties("platformPlugins")
            .split(",")
            .map(String::trim)
            .filter(String::isNotEmpty)
    )
}

changelog {
    version.set(properties("pluginVersion"))
    groups.set(emptyList<String>())
}

sourceSets {
    main {
        java {
            srcDirs("gen")
        }
        resources {
            exclude("debugger/**")
        }
    }
}

tasks {
    withType<JavaCompile> {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "17"
        kotlinOptions.freeCompilerArgs = listOf(
            "-Xjvm-default=all",
            "-Xopt-in=kotlin.contracts.ExperimentalContracts"
        )
    }

    patchPluginXml {
        version.set(properties("pluginVersion"))
        sinceBuild.set(properties("pluginSinceBuild"))

        changeNotes.set(
            provider {
                changelog.getLatest().toHTML()
            }
        )
    }

    val debuggerArchitectures = arrayOf("x86", "x64")

    register<Download>("downloadEmmyLuaDebugger") {
        val debuggerVersion = properties("emmyLuaDebuggerVersion")

        src(arrayOf(
            "https://github.com/EmmyLua/EmmyLuaDebugger/releases/download/${debuggerVersion}/emmy_core.so",
            "https://github.com/EmmyLua/EmmyLuaDebugger/releases/download/${debuggerVersion}/emmy_core.dylib",
            *debuggerArchitectures.map {
                "https://github.com/EmmyLua/EmmyLuaDebugger/releases/download/${debuggerVersion}/emmy_core@${it}.zip"
            }.toTypedArray()
        ))

        dest("temp")
    }

    register<Copy>("extractEmmyLuaDebugger") {
        dependsOn("downloadEmmyLuaDebugger")

        debuggerArchitectures.forEach {
            from(zipTree("temp/emmy_core@${it}.zip")) {
                into(it)
            }
        }

        destinationDir = file("temp")
    }

    register<Copy>("copyEmmyLuaDebugger") {
        dependsOn("extractEmmyLuaDebugger")

        // Windows
        debuggerArchitectures.forEach {
            from("temp/${it}/") {
                into("debugger/emmy/windows/${it}")
            }
        }

        // Linux
        from("temp") {
            include("emmy_core.so")
            into("debugger/emmy/linux")
        }

        // Mac
        from("temp") {
            include("emmy_core.dylib")
            into("debugger/emmy/mac")
        }

        destinationDir = file("src/main/resources")
    }

    buildPlugin {
        dependsOn("copyEmmyLuaDebugger")

        val resourcesDir = "src/main/resources"

        from(fileTree(resourcesDir)) {
            include("debugger/**")
            into("/${project.name}/classes")
        }

        from(fileTree(resourcesDir)) {
            include("!!DONT_UNZIP_ME!!.txt")
            into("/${project.name}")
        }
    }

    runPluginVerifier {
        ideVersions.set(
            properties("pluginVerifierIdeVersions")
                .split(',')
                .map(String::trim)
                .filter(String::isNotEmpty)
        )
    }

    publishPlugin {
        dependsOn("patchChangelog")
        token.set(System.getenv("PUBLISH_TOKEN"))
        channels.set(listOf(
            properties("pluginVersion")
                .split("-")
                .getOrElse(1) { "default" }
                .split(".")
                .first()
        ))
    }
}
