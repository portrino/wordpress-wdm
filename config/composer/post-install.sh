#!/usr/bin/env bash

source $(dirname "$0")/functions.sh
COMPOSER_DIR=$(pwd)
WP_SOURCE_DIR="${COMPOSER_DIR}/public/wp-source/"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

cd "${COMPOSER_DIR}"

if [[ -f "${COMPOSER_DIR}/.env" ]]; then
    source "${COMPOSER_DIR}/.env"
fi

if [[ ! -f "${COMPOSER_DIR}/public/index.php" ]]; then
    cecho "Copy index.php from wordpress source directory to doc-root... " ${default} 1
    cp "${COMPOSER_DIR}"/public/wp-source/index.php "${COMPOSER_DIR}"/public/index.php && cecho "Done" ${green} || cecho "Fail" ${red}

    cecho "Update paths to wordpress core in copied index.php... " ${default} 1
    sed -i "s/\\/wp-blog-header/\\/wp-source\\/wp-blog-header/g" "${COMPOSER_DIR}"/public/index.php && cecho "Done" ${green} || cecho "Fail" ${red}
fi

if [[ ! -f "${COMPOSER_DIR}/public/.htaccess" ]]; then
    cecho "Create default .htaccess file in doc-root... " ${default} 1
cat >> "${COMPOSER_DIR}/public/.htaccess" << EOL
# BEGIN WordPress
# The directives (lines) between "BEGIN WordPress" and "END WordPress" are
# dynamically generated, and should only be modified via WordPress filters.
# Any changes to the directives between these markers will be overwritten.
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>

# END WordPress
EOL
cecho "Done" ${green}
fi

if [[ ! -f "${COMPOSER_DIR}/public/wp-config.php" ]]; then
    cecho "Create default wp-config.php file in doc-root... " ${default} 1
cat >> "${COMPOSER_DIR}/public/wp-config.php" << EOL
<?php
/**
 * Do not edit this file. Edit the config files found in the config/system/ dir instead.
 * This file is required in the root directory so WordPress can find it.
 * WP is hardcoded to look in its own directory or one directory up for wp-config.php.
 */
require_once dirname(__DIR__) . '/vendor/autoload.php';
require_once dirname(__DIR__) . '/config/system/settings.php';
require_once ABSPATH . 'wp-settings.php';
EOL
cecho "Done" ${green}
fi


if [[ ! -d "${COMPOSER_DIR}"/public/wp-content/uploads/ ]] && [[ ${WP_IS_SET_UP} -eq 0 ]]; then
    cecho "Run (forced) Wordpress installation" ${green}
    "${COMPOSER_DIR}"/bin/wp core install --url="${WP_ENV_DOMAIN}" --title="${WP_INSTALL_SITE_TITLE}" --admin_user="${WP_INSTALL_ADMIN_USER}" --admin_password="${WP_INSTALL_ADMIN_PASSWORD}" --admin_email="${WP_INSTALL_ADMIN_EMAIL}" --path="${WP_SOURCE_DIR}"
fi
cecho "Run database migrations" ${green}
"${COMPOSER_DIR}"/bin/wp core update-db --path="${WP_SOURCE_DIR}"

cecho "Run language updates (core, plugins, themes)" ${green}
"${COMPOSER_DIR}"/bin/wp language core update --path="${WP_SOURCE_DIR}"
"${COMPOSER_DIR}"/bin/wp language plugin update --all --path="${WP_SOURCE_DIR}"
"${COMPOSER_DIR}"/bin/wp language theme update --all --path="${WP_SOURCE_DIR}"

cecho "Activate all existing plugins by default" ${green}
"${COMPOSER_DIR}"/bin/wp plugin activate --all --path="${WP_SOURCE_DIR}"

cecho "Activate theme" ${green}
"${COMPOSER_DIR}"/bin/wp theme activate twentytwentyfour --path="${WP_SOURCE_DIR}"

cecho "Flush wordpress cache" ${green}
"${COMPOSER_DIR}"/bin/wp cache flush --path="${WP_SOURCE_DIR}"

if [[ -d "${COMPOSER_DIR}"/public/wp-content/uploads/ ]] && [[ ${WP_IS_SET_UP} -eq 0 ]]; then
    cecho " "
    cecho "Congratulations! Successfully installed your WordPress :-)" ${cyan_bold}
    cecho " "
    cecho "Backend: ${WP_HOME}wp-admin/" ${cyan}
    cecho "Frontend: ${WP_HOME}" ${cyan}
fi

cd "${COMPOSER_DIR}"
