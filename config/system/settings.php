<?php
/**
 * Your base production configuration goes in this file. Environment-specific
 * overrides go in their respective config/environments/{{WP_ENV}}.php file.
 *
 * A good default policy is to deviate from the production config as little as
 * possible. Try to define as much of your configuration in this file as you
 * can.
 */

use Roots\WPConfig\Config;
use function Env\env;

/**
 * Directory containing all the site's files
 *
 * @var string
 */
$rootDirectory = dirname(__DIR__, 2);

/**
 * Document Root
 *
 * @var string
 */
$documentRootDirectory = $rootDirectory . '/public';

/**
 * Use Dotenv to set required environment variables and load .env file in root
 * .env.local will override .env if it exists
 */
if (file_exists($rootDirectory . '/.env')) {
    $env_files = file_exists($rootDirectory . '/.env.local')
        ? ['.env', '.env.local']
        : ['.env'];

    $dotenv = Dotenv\Dotenv::createUnsafeImmutable($rootDirectory, $env_files, false);

    $dotenv->load();

    $dotenv->required(['WP_HOME']);
    if (!env('DATABASE_URL')) {
        $dotenv->required(['WP_INSTALL_DB_NAME', 'WP_INSTALL_DB_USER', 'WP_INSTALL_DB_PASSWORD']);
    }
}

/**
 * Set up our global environment constant and load its config first
 * Default: production
 */
define('WP_ENV', env('WP_ENV') ?: 'production');

/**
 * Infer WP_ENVIRONMENT_TYPE based on WP_ENV
 */
if (!env('WP_ENVIRONMENT_TYPE') && in_array(WP_ENV, ['production', 'staging', 'development', 'local'])) {
    Config::define('WP_ENVIRONMENT_TYPE', WP_ENV);
}

/**
 * URLs
 */
Config::define('WP_HOME', env('WP_HOME'));
Config::define('WP_SITEURL', rtrim(env('WP_HOME'), '/') . '/wp-source');

/**
 * Custom Content Directory
 */
Config::define('CONTENT_DIR', '/wp-content');
Config::define('WP_CONTENT_DIR', $documentRootDirectory . Config::get('CONTENT_DIR'));
Config::define('WP_CONTENT_URL', Config::get('WP_HOME') . Config::get('CONTENT_DIR'));

/**
 * DB settings
 */
if (env('DB_SSL')) {
    Config::define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);
}

Config::define('DB_NAME', env('WP_INSTALL_DB_NAME'));
Config::define('DB_USER', env('WP_INSTALL_DB_USER'));
Config::define('DB_PASSWORD', env('WP_INSTALL_DB_PASSWORD'));
Config::define('DB_HOST', env('WP_INSTALL_DB_HOST') ?: 'localhost');
Config::define('DB_CHARSET', env('WP_INSTALL_DB_CHARSET') ?: 'utf8mb4');
Config::define('DB_COLLATE', '');
$table_prefix = env('WP_INSTALL_DB_PREFIX') ?: 'wp_';

if (env('WP_INSTALL_DATABASE_URL')) {
    $dsn = (object) parse_url(env('WP_INSTALL_DATABASE_URL'));

    Config::define('DB_NAME', substr($dsn->path, 1));
    Config::define('DB_USER', $dsn->user);
    Config::define('DB_PASSWORD', isset($dsn->pass) ? $dsn->pass : null);
    Config::define('DB_HOST', isset($dsn->port) ? "{$dsn->host}:{$dsn->port}" : $dsn->host);
}

/**
 * Authentication Unique Keys and Salts
 */
Config::define('AUTH_KEY', env('AUTH_KEY'));
Config::define('SECURE_AUTH_KEY', env('SECURE_AUTH_KEY'));
Config::define('LOGGED_IN_KEY', env('LOGGED_IN_KEY'));
Config::define('NONCE_KEY', env('NONCE_KEY'));
Config::define('AUTH_SALT', env('AUTH_SALT'));
Config::define('SECURE_AUTH_SALT', env('SECURE_AUTH_SALT'));
Config::define('LOGGED_IN_SALT', env('LOGGED_IN_SALT'));
Config::define('NONCE_SALT', env('NONCE_SALT'));

/**
 * Custom Settings
 */
Config::define('AUTOMATIC_UPDATER_DISABLED', env('AUTOMATIC_UPDATER_DISABLED') ?: true);
Config::define('DISABLE_WP_CRON', env('DISABLE_WP_CRON') ?: false);

// Disable the plugin and theme file editor in the admin
Config::define('DISALLOW_FILE_EDIT', env('DISALLOW_FILE_EDIT') ?: true);

// Disable plugin and theme updates and installation from the admin
Config::define('DISALLOW_FILE_MODS', env('DISALLOW_FILE_MODS') ?: true);

// Limit the number of post revisions
Config::define('WP_POST_REVISIONS', env('WP_POST_REVISIONS') ?? true);

/**
 * Debugging Settings
 */
Config::define('WP_DEBUG_DISPLAY', false);
Config::define('WP_DEBUG_LOG', false);
Config::define('SCRIPT_DEBUG', false);
//ini_set('display_errors', '0');

/**
 * Allow WordPress to detect HTTPS when used behind a reverse proxy or a load balancer
 * See https://codex.wordpress.org/Function_Reference/is_ssl#Notes
 */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

$environmentConfig = __DIR__ . '/environments/' . WP_ENV . '.php';

if (file_exists($environmentConfig)) {
    require_once $environmentConfig;
}

Config::apply();

/**
 * Bootstrap WordPress
 */
if (!defined('ABSPATH')) {
    define('ABSPATH', $documentRootDirectory . '/');
}
