# PMC-UPDATER
## Installation [EN]
- Download the latest release
- Unzip & drop the resource inside your resources folder
- Add to your .cfg file `ensure pmc-updater` **It should be the last one on start!**
## Instalación [ES]
- Descarga la última version
- Descomprime el archivo y añade el recurso a tu carpeta resources
- Añade a tu .cfg `ensure pmc-updater` **¡Debe ser el último en iniciarse!**
---
## Tutorial
#### git update
| Parameter | Description |
|-|-|
| resource name | Check updates for the resource, only if they are made to be updated with pmc-updater. Downloaded with 'git clone' works, check the command below. |

Command example:

`git update pmc-updater`

#### git clone
| Parameter | Description |
|-|-|
| github url | The github repository URL, example: https://github.com/pitermcflebor/pmc-updater |
| directory | *Optional, default root resources folder* The path where the resource will be cloned. |

Command example:

`git clone https://github.com/pitermcflebor/pmc-updater /[test]`

*Only add a slash when the folder starts with some special char like `[`*

`git clone https://github.com/pitermcflebor/pmc-updater /[core]//[pmc]`

*Don't write the resource name, it will be the github repo name!*

### Example
https://streamable.com/xn8dv0

---
## Resource developers
### How to create a resource compatible with pmc-updater?
- Add your resource to the repositore following some of these structures:
  - *this `...` means your resource files*
  - `root/your-resource/...` the folder name should be the same as the repo name!
  - `root/...`
- Create a release inside your repo so the pmc-updater can check the latest version!
- Add inside your `fxmanifest.lua`:
  - `pmc_updates 'yes'` This will enable auto-updates.
  - `pmc_github 'github.com/user/repo-name'` The github repo link.
  - `pmc_version '1.0'` This should be the same tag name for the latest release!

**IMPORTANT:** Any file started with dot (.) will be ignored!

---
## How to override the Github Limitation
- Create a API Token [here](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token#creating-a-token)
- Once you have your token, write the token inside the file `.authkey`
*it won't be removed or overwritten on update!*
*with the token you have 5000 API requests per hour.*
