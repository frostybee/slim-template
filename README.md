# Slim-Based Application Skeleton

This repository contains an application skeleton for creating REST-based Web services. The latest version of the [**Slim micro framework**](https://www.slimframework.com/) is being used.

## How Do I Use/Deploy this Template?

Follow the instructions below in the specified order:

1. Download this repository as `.zip` file.
2. Extract the downloaded `slim-template-main.zip` file locally.
3. Copy the `slim-template-main` folder into your Web server's **document root** (that is, `htdocs`)
4. Rename the `slim-template-main` folder to `[project_name]-api`. For example, `worldcup-api`
5. Open your `[project_name]-api` folder in VS Code
6. In the `.htaccess` file, change the specified subdirectory that is assigned to the `RewriteBase` directive.  The name of the subdirectory must be the same as the one you chose in Step 4). For example, change from `RewriteBase /slim-template` to  `RewriteBase /worldcup-api`
7. In `index.php`, change the applications's base path directory from  `$app->setBasePath("/slim-template");` to `$app->setBasePath("/[project_name]-api");` where `[project_name]` is the name of the subdirectory you chose in Step 4).
8. Run the following command to install or update the required dependencies in a VS Code terminal window (hit ``` Ctrl+` ```)

```bat
composer.bat update
```

**```NOTE:```** You can always clone this repository. However, if you do, you need to remove the ```.git``` ***hidden*** directory before you copy this template over to ```htdocs```

## How Do I Connect to a Database?

The database credentials info are stored in `app/config/app_config.php`.

* Change the value of DB_NAME constant to reflect the name of the database to be used by your slim app.
* You may also want to change the database connection credentials in that file.

## Dependencies

---

The following dependencies have been already added to this template.

1. `slim/slim:"4.*"`
2. `guzzlehttp/guzzle`
3. `vlucas/phpdotenv`
4. `firebase/php-jwt`
5. `monolog/monolog`

Optional: you can use `composer` to either update the referenced dependencies or add additional ones based on your implementation's requirements.

## VS Code Extensions

---
Listed below are recommended VS Code extensions for Web development. However, most of them are already  included in `.vscode/extensions.json`

### PHP, HTML, and JavaScript

1. [Thunder Client](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client)
2. [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
3. [GitLens — Git supercharged](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
4. [PHP IntelliSense](https://marketplace.visualstudio.com/items?itemName=zobo.php-intellisense)
5. [PHP Intelephense](https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client)
6. [PHP Debug](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug)
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
