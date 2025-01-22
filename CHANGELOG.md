# CHANGELOG

## v1.29.2 - 2025/01/22

- Upgrade **Alpine** from *3.20* to *3.21.2*
- Using multi-stage image
- Image size reduce from *81.3 MB* to *41.4 MB*

### Vulnerabilities

NAME        INSTALLED  FIXED-IN                                              TYPE  VULNERABILITY   SEVERITY
libcrypto3  3.3.2-r4   1.0.2zl, 1.1.1zb, 3.0.16, 3.1.8, 3.2.4, 3.3.3, 3.4.1  apk   CVE-2024-13176  Unknown
libssl3     3.3.2-r4   1.0.2zl, 1.1.1zb, 3.0.16, 3.1.8, 3.2.4, 3.3.3, 3.4.1  apk   CVE-2024-13176  Unknown
linux-pam   1.6.1-r1                                                         apk   CVE-2024-10041  Medium

### Commits

- *99c8b6b* feat(svc-syncrelay): get exe version from the exe with parameter '-version'
- *7e67254* chore: remove version label
- *9485776* chore: better description in LABEL
- *407bcd1* feat: use one RUN command in final stage instead of 3
- *8cfd85c* feat: copy files from 'builder' stage
- *7db6660* feat: add a 'builder' stage and move s6-overlay to this step

---

## v1.27.7-r3 - 2024/07/17

### Changes

- Upgrade **Alpine** from *3.19* to *3.20*
- Upgrade **s6-overlay** from *3.1.6.2* to *3.2.0.0*
- Upgrade **syncthing-utils** from *1.27.0-r1* to *1.27.7-r3*
- Version label will now follow package version

### Fix

- All previous vulnerabilities have been fixed!

#### Previous vulnerabilites

```
NAME                        INSTALLED   FIXED-IN    TYPE       VULNERABILITY        SEVERITY
busybox                     1.36.1-r15  1.36.1-r16  apk        CVE-2023-42366       Medium
busybox                     1.36.1-r15  1.36.1-r19  apk        CVE-2023-42365       Medium
busybox                     1.36.1-r15  1.36.1-r19  apk        CVE-2023-42364       Medium
busybox                     1.36.1-r15  1.36.1-r17  apk        CVE-2023-42363       Medium
busybox-binsh               1.36.1-r15  1.36.1-r16  apk        CVE-2023-42366       Medium
busybox-binsh               1.36.1-r15  1.36.1-r19  apk        CVE-2023-42365       Medium
busybox-binsh               1.36.1-r15  1.36.1-r19  apk        CVE-2023-42364       Medium
busybox-binsh               1.36.1-r15  1.36.1-r17  apk        CVE-2023-42363       Medium
golang.org/x/crypto         v0.15.0     0.17.0      go-module  GHSA-45x7-px36-x8w8  Medium
golang.org/x/net            v0.18.0     0.23.0      go-module  GHSA-4v7x-pqxf-cx7m  Medium
google.golang.org/protobuf  v1.31.0     1.33.0      go-module  GHSA-8r3f-844c-mc37  Medium
libcrypto3                  3.1.4-r5    3.1.6-r0    apk        CVE-2024-5535        Critical
libcrypto3                  3.1.4-r5    3.1.6-r0    apk        CVE-2024-4741        Unknown
libcrypto3                  3.1.4-r5    3.1.5-r0    apk        CVE-2024-4603        Unknown
libcrypto3                  3.1.4-r5    3.1.4-r6    apk        CVE-2024-2511        Unknown
libssl3                     3.1.4-r5    3.1.6-r0    apk        CVE-2024-5535        Critical
libssl3                     3.1.4-r5    3.1.6-r0    apk        CVE-2024-4741        Unknown
libssl3                     3.1.4-r5    3.1.5-r0    apk        CVE-2024-4603        Unknown
libssl3                     3.1.4-r5    3.1.4-r6    apk        CVE-2024-2511        Unknown
libuv                       1.47.0-r0               apk        CVE-2024-24806       High
libxml2                     2.11.7-r0   2.11.8-r0   apk        CVE-2024-34459       Unknown
linux-pam                   1.5.3-r7                apk        CVE-2024-22365       Medium
nghttp2-libs                1.58.0-r0               apk        CVE-2024-28182       Medium
ssl_client                  1.36.1-r15  1.36.1-r16  apk        CVE-2023-42366       Medium
ssl_client                  1.36.1-r15  1.36.1-r19  apk        CVE-2023-42365       Medium
ssl_client                  1.36.1-r15  1.36.1-r19  apk        CVE-2023-42364       Medium
ssl_client                  1.36.1-r15  1.36.1-r17  apk        CVE-2023-42363       Medium
stdlib                      go1.21.8                go-module  CVE-2024-24790       Critical
stdlib                      go1.21.8                go-module  CVE-2024-24791       High
stdlib                      go1.21.8                go-module  CVE-2024-24789       Medium
stdlib                      go1.21.8                go-module  CVE-2024-24787       Medium
stdlib                      go1.21.8                go-module  CVE-2023-45288       Unknown
```

### Commits

- *1c2fca3*: refactor(svc-syncrelay): get package version for header
- *a5fff5f*: refactor(dockerfile): remove environment version variable
- *abda54c*: chore(dockerfile): change label version
- *614b54a*: fix(profile): add color to ls alias
- *f50cf38*: feat(dockerfile): upgrade s6-overlay from 3.1.6.2 to 3.2.0.0
- *ef53ead*: feat(dockerfile): upgrade alpine from 3.19 to 3.20

---

## v1.0.0 - 2024/03/16

- First version of this Docker image.
