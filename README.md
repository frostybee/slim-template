# Starter Template

This repository contains an application skeleton for creating REST-based Web services using the latest version of the [**Slim micro framework**](https://www.slimframework.com/).

## How Do I Use/Deploy this Template?

Follow the instructions below in the specified order:

1. Download this repository as `.zip` file.
2. Extract the downloaded `slim-template-main.zip` file locally.
3. Copy the `slim-template-main` folder into your Web server's **document root** (that is, `htdocs`)
4. Rename the `slim-template-main` folder to `[project_name]-api`. For example, `worldcup-api`
5. Open your `[project_name]-api` folder in VS Code
6. Open a terminal window in VS Code (hit ``` Ctrl+` ```), and run `composer.bat update` command to install or update the required dependencies. Make sure that `Command Prompt` is selected (the dropdown menu in the upper-right corner).
7. Adjust your database credentials, **see below**.

**```NOTE:```** You can always clone this repository. However, if you do, you need to remove the ```.git``` ***hidden*** directory before you copy this template over to ```htdocs```

## How Do I Configure My Database Connection?

Follow the outlined instructions in [config/env.example.php](config/env.example.php)

* Change the value of the `database` variable to reflect the name of the database to be used by your slim app.
* You may also want to change the connection credentials in that file.

## On Using Environment Variables

Sensitive information used in app such as your database credentials, API key, etc. MUST not be pushed into your Git repo.

Do not use `.env` files for storing environment specific application settings/configurations. Dotenv [is not meant to be used in production](https://github.com/vlucas/phpdotenv/issues/76#issuecomment-87252126)

Just Google: "DB_PASSWORD" filetype:env [Google](https://www.google.ch/search?q=%22DB_PASSWORD%22+filetype:env)

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
    "when": "textInputFocus"
  },
  {
    "key": "ctrl+shift+j",
    "command": "type",
    "args": {
      "text": "$this->"
    },
    "when": "textInputFocus"
  },
  {
    "key": "ctrl+shift+k",
    "command": "type",
    "args": {
      "text": "->"
    },
    "when": "textInputFocus"
  },
  {
    "key": "ctrl+shift+l",
    "command": "type",
    "args": {
      "text": "<?php"
    },
    "when": "textInputFocus"
  },
  {
    "key": "shift+enter",
    "command": "type",
    "args": {
      "text": "$"
    },
    "when": "textInputFocus"
  },
  {
    "key": "shift+space",
    "command": "type",
    "args": {
      "text": "_"
    },
    "when": "textInputFocus"
  },
  ```

## VS Code Extensions

Listed below are recommended VS Code extensions for Web development. However, most of them are already  included in [.vscode/extensions.json](.vscode/extensions.json)

### PHP, HTML, and JavaScript

1. [Thunder Client](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client)
2. [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
3. [GitLens — Git supercharged](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
4. [PHP IntelliSense](https://marketplace.visualstudio.com/items?itemName=zobo.php-intellisense)
5. [PHP Intelephense](https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client)
7. [PHP Extension Pack](https://marketplace.visualstudio.com/items?itemName=xdebug.php-pack)
8. [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
9. [JavaScript (ES6) code snippets](https://marketplace.visualstudio.com/items?itemName=xabikos.JavaScriptSnippets)
10. [HTML Snippets](https://marketplace.visualstudio.com/items?itemName=abusaidm.html-snippets)

### Markdown

1. [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
2. [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
3. [Markdown Preview Github Styling](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles)
4. [Markdown PDF](https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf)

### Productivity

1. [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
2. [Bookmarks](https://marketplace.visualstudio.com/items?itemName=alefragnani.Bookmarks)

### Appearance

1. [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme)

#### Dark Themes

1. [Evondev Dracula](https://marketplace.visualstudio.com/items?itemName=evondev.dracula-high-contrast)
2. [Tokyo Night](https://marketplace.visualstudio.com/items?itemName=enkia.tokyo-night)
3. [Dracula Official](https://marketplace.visualstudio.com/items?itemName=dracula-theme.theme-dracula)
