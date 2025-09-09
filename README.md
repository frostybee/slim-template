- [Starter Template](#starter-template)
  - [How Do I Use/Deploy this Template?](#how-do-i-usedeploy-this-template)
  - [How Do I Configure My Database Connection?](#how-do-i-configure-my-database-connection)
  - [On Using Environment Variables](#on-using-environment-variables)
  - [Useful VS Code Keybindings](#useful-vs-code-keybindings)
  - [Adding Fira Code Font to VS Code Portable](#adding-fira-code-font-to-vs-code-portable)
  

# Starter Template

This repository contains an application skeleton for creating REST-based Web services using the latest version of the [**Slim micro framework**](https://www.slimframework.com/).

## How Do I Use/Deploy this Template?

Follow the instructions below in the specified order:

1. Download this repository as a `.zip` file.
2. Extract the downloaded `slim-template-main.zip` file locally.
3. Copy the `slim-template-main` folder into your web server's **document root** (i.e., `htdocs`).
4. Rename the `slim-template-main` folder to `[project_name]-api` (for example, `worldcup-api`).
5. Open your `[project_name]-api` folder in VS Code.
6. If you are using Wampoon, open a terminal window in VS Code (press `Ctrl+`\`) and select the `Command Prompt`from the dropdown menu in the upper-right corner. Then run`"../../composer.bat" update` (**NOTE**: double quotes are required) to install or update the required dependencies.

   * If you are not using Wampoon, just run Composer from the command line.
7. In the `config` folder, make a copy of `env.example.php` and rename it to `env.php`.
8. Adjust your database credentials (**see below**).

**```NOTE:```** You can always clone this repository. However, if you do, you need to remove the ```.git``` ***hidden*** directory before you copy this template over to ```htdocs```

## How Do I Configure My Database Connection?

Follow the outlined instructions in [config/env.example.php](config/env.example.php)

* Change the value of the `database` variable to reflect the name of the database to be used by your slim app.
* You may also want to change the connection credentials in that file.

## On Using Environment Variables

Sensitive information used in app such as your database credentials, API key, etc. MUST not be pushed into your Git repo.

Do not use `.env` files for storing environment specific application settings/configurations. Dotenv [is not meant to be used in production](https://github.com/vlucas/phpdotenv/issues/76#issuecomment-87252126)

Just Google: "DB_PASSWORD" filetype:env
Alternatively, you can visit the following link: [Google env search](https://www.google.ch/search?q=%22DB_PASSWORD%22+filetype:env)

Instead, follow the instructions that are detailed in [config/env.example.php](config/env.example.php)


## Useful VS Code Keybindings

Below are keybindings that speeds up the insertion of special characters and keywords while editing a `.php` file. These bindings need to be added to your VS Code's keybindings.json

```json
  {
    "key": "alt+shift+p",
    "command": "type",
    "args": {
      "text": "=>"
    },
    "when": "textInputFocus && editorLangId == php"
  },
  {
    "key": "ctrl+shift+j",
    "command": "type",
    "args": {
      "text": "$this->"
    },
    "when": "textInputFocus && editorLangId == php"
  },
  {
    "key": "ctrl+shift+k",
    "command": "type",
    "args": {
      "text": "->"
    },
    "when": "textInputFocus && editorLangId == php"
  },
  {
    "key": "ctrl+shift+l",
    "command": "type",
    "args": {
      "text": "<?php"
    },
    "when": "textInputFocus && editorLangId == php"
  },
  {
    "key": "shift+enter",
    "command": "type",
    "args": {
      "text": "$"
    },
    "when": "textInputFocus && editorLangId == php"
  },
  {
    "key": "shift+space",
    "command": "type",
    "args": {
      "text": "_"
    },
    "when": "textInputFocus && editorLangId == php"
  }
  ```

## Adding Fira Code Font to VS Code Portable

1. Open your VS Code installation folder,
2. Navigate to:
    ```batch 
    resources > app > out > vs >code > electron-sandbox > workbench
    ```

3. Open `workbench.js` in a text editor,
4. Add the following to the end of `workbench.js` then save it,

    ```javascript
    var styleNode = document.createElement('style'); 
    styleNode.type = "text/css"; 
    var styleText = document.createTextNode(`
        @font-face{
            font-family: 'Fira Code';
            src: url('https://raw.githubusercontent.com/tonsky/FiraCode/master/distr/eot/FiraCode-Regular.eot') format('embedded-opentype'),
                url('https://raw.githubusercontent.com/tonsky/FiraCode/master/distr/woff2/FiraCode-Regular.woff2') format('woff2'),
                url('https://raw.githubusercontent.com/tonsky/FiraCode/master/distr/woff/FiraCode-Regular.woff') format('woff'),
                url('https://raw.githubusercontent.com/tonsky/FiraCode/master/distr/ttf/FiraCode-Regular.ttf') format('truetype');
            font-weight: normal;
            font-style: normal;
        }`); 
    styleNode.appendChild(styleText); 
    document.getElementsByTagName('head')[0].appendChild(styleNode);
    ```
5. Open VS Code
6. Open `settings.json` then add the following:
    ```json
    "editor.fontFamily": "Fira Code",
    "editor.fontLigatures": true,
    "editor.fontWeight": "400" // normal
    ```
