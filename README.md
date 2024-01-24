# Web Developer Meetup - WordPress Composer Boilerplate

## Development Setup

> Local development setup is based on ddev (https://ddev.readthedocs.io/)

1. Create a new project directory - e.g. in your home directory
    - `mkdir ~/wordpress-wdm` and change into the directory
    - clone the repository via `git clone https://github.com/portrino/wordpress-wdm.git .`
2. "Start" the project and import database (and project assets if needed)
    - run `ddev start` to start the project
    - use `ddev import-db -f path/to/domain.tld.sql.gz` to import the project mysql dump
3. "Install" the project
    - first, run `ddev composer install --no-scripts` to install all required packages
    - afterward, run `ddev composer install` so that the configured composer scripts are executed as defined
        - this will create an `.env` file with the help of a wizard using the `.env.dist` as base. This script/ wizard
          always checks, if the `.env.dist` has been changed and if so, will ask you to set/ add the missing variable(s)
          to you local `.env` file as well
        - if you have not unpacked any assets, the `wp-content/uploads` directory may have to be created manually
          `mkdir public/wp-content/uploads`
          - if you set the `WP_IS_SET_UP` variable in your `.env` file to `0` and the `wp-content/uploads` is not existing
            yet, then composer post install scripts will run an unattended WordPress installation using [WP-CLI](https://wp-cli.org/) 
4. Run `ddev launch` to open https://wordpress-wdm.ddev.site/ in your local browser

## Tips & Tricks

## Acknowledgements

The WDM WordPress Boilerplate wouldn't be possible without these amazing open-source projects.

- [`cedaro/satispress`](https://github.com/cedaro/satispress)
- [`composer/installers`](https://github.com/composer/installers)
- [`johnpbloch/wordpress`](https://github.com/johnpbloch/wordpress)
- [`outlandish/wpackagist`](https://github.com/outlandishideas/wpackagist)
- [`oscarotero/env`](https://github.com/oscarotero/env)
- [`portrino/companienv`](https://github.com/portrino/companienv)
- [`roots/wordpress`](https://github.com/roots/wordpress)
- [`vlucas/phpdotenv`](https://github.com/vlucas/phpdotenv)
- [`wp-cli/wp-cli`](https://github.com/wp-cli/wp-cli)

### Based on other great boilerplates

- [`roots/bedrock`](https://github.com/roots/bedrock)
- [`vinkla/wordplate`](https://github.com/vinkla/wordplate)
