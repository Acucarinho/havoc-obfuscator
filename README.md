# havoc-obfuscator

This project provides enhancements and fixes for the Havoc C2 framework, including:

- Custom headers and Havoc fonts for MiniMice.
- IIS 8.5 impersonation to better mimic a legitimate Microsoft IIS server, including removing the `X-Havoc: True` header to avoid detection.
- A fix in `./teamserver/cmd/server/teamserver.go` addressing an issue where Havoc sends a request to `/`, receives a 301 redirect to `/home/`, but `/home/` returns a 404 with length 0.
- The included script fixes this problem by serving a fake page instead of a 404 error.
- Refactors the Havoc C2 codebase by renaming all occurrences of the commands `Shell` (uppercase and lowercase variants) to `MiniMice`/`miniMice`, and the CLI command `DotRunner` to `miniMiceDot`, ensuring a consistent and unified command naming scheme across the teamserver, client, and payloads.

## Installation

1. Clone the Havoc repository:
   ```bash
   git clone https://github.com/HavocFramework/Havoc.git
   ```
   Change to the Havoc directory:

   ```bash
   cd Havoc
   ```
2. Download the script and the fake page using `wget`:

   ```bash
   wget -4 https://raw.githubusercontent.com/Acucarinho/havoc-obfuscator/main/havoc-obfuscator.sh
   wget -4 https://raw.githubusercontent.com/Acucarinho/havoc-obfuscator/main/404_iis.html
   ```

3. Give execution permission to the script:
      ```bash
      chmod +x havoc-obfuscator.sh
      ```

4. Run the script
  ```bash
./havoc-obfuscator.sh
```
## Compilation

### Compile the Teamserver

Navigate to the `teamserver` directory and build the teamserver executable:

```bash
cd teamserver
go build -o havoc-teamserver
```

### Compile the Client

Navigate to the `client` directory, clean previous builds, create the build directory, and compile the client:

```bash
cd client && rm -rf Build && mkdir Build && cd Build && cmake .. && make -j2
```

## Usage

To start working with Havoc C2 after your modifications, follow these steps from the root directory of the Havoc project:

### 1. Start the Teamserver

Run the teamserver with a specific profile and verbose output:

```bash
./teamserver/havoc-teamserver server --profile profiles/windows-update.yaotl -v
```

### 2. Start the Client

Change to the client directory and launch the client using the new unified command name:

```bash
cd client
./MiniMice client
```

## Tested On

This software has been tested on:

- **Kali Linux 2025.2**

## Notes

- Use a malleable C2 profile such as the [windows-update profile](https://github.com/Altoid0/Gom-Jabbar/blob/master/Profiles/Havoc/windows-update.yaotl).
- Avoid using the default port `40056`; choose a different port.
- Use proxies or redirectors to help evade JARM fingerprinting attacks.

## Inspiration

This project was inspired by the techniques and insights presented in:

[**How to Hack Like a Ghost: Breaching the Cloud (2021)**](https://www.amazon.com.br/Hack-Like-Ghost-Sparc-Flow/dp/1718501269)

## To-Do List

- [ ] Generate custom certificates to avoid JARM hashes
- [ ] Fix "Client sent an HTTP request to an HTTPS server" error for HTTP requests
- [x] Change commands such as Execute and Shell
