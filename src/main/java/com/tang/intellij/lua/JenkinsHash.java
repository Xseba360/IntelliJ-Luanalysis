/*
 * Copyright (c) 2022
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.tang.intellij.lua;

import org.jetbrains.annotations.NotNull;

public class JenkinsHash {
    private final int hash;

    public JenkinsHash(@NotNull String str) {
        int hash = 0;
        int length = str.length();
        for (int i = 0; i < length; i++) {
            hash += JenkinsHash_to_lower(str.charAt(i));
            hash += (hash << 10) & 0xFFFFFC00;
            hash ^= (hash >> 6) & 0x03FFFFFF;
        }
        hash += (hash << 3) & 0xFFFFFFFC;
        hash ^= (hash >> 11) & 0x001FFFFF;
        hash += (hash << 15) & 0xFFFF8000;
        this.hash = hash;
    }

    private static int JenkinsHash_to_lower(char c) {
        return (c >= 'A' && c <= 'Z') ? c + ('a' - 'A') : c;
    }

    public int getHash() {
        return hash;
    }
}
