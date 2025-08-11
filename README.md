# havoc-obfuscator

This project provides enhancements and fixes for the Havoc C2 framework, including:

- Custom headers and Havoc fonts for MiniMice.
- IIS 8.5 impersonation to better mimic a legitimate Microsoft IIS server, including removing the `X-Havoc: True` header to avoid detection.
- A fix in `./teamserver/cmd/server/teamserver.go` addressing an issue where Havoc sends a request to `/`, receives a 301 redirect to `/home/`, but `/home/` returns a 404 with length 0.
- The included script fixes this problem by serving a fake page instead of a 404 error.

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

## Notes

- Use a malleable C2 profile such as the [windows-update profile](https://github.com/Altoid0/Gom-Jabbar/blob/master/Profiles/Havoc/windows-update.yaotl).
- Avoid using the default port `40056`; choose a different port.
- Use proxies or redirectors to help evade JARM fingerprinting attacks.
