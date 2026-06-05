# Home Assistant Wiki.js Add-on

This repository provides a Home Assistant OS add-on for running Wiki.js as a
sidecar service.

## Add-on

- Slug: `wikijs`
- Exposed port: `3000/tcp`
- Ingress: disabled
- Network: bridged add-on networking (`host_network: false`)
- Architecture: `aarch64` only, intended for Home Assistant Yellow / CM4
- Wiki.js image: `ghcr.io/requarks/wiki:2`

## MariaDB setup

The add-on defaults to the Home Assistant MariaDB add-on hostname
`core-mariadb` on port `3306`.

### Option 1: MariaDB add-on configuration

In the Home Assistant MariaDB add-on configuration, add a database, login, and
rights entry for Wiki.js:

```yaml
databases:
  - wikijs
logins:
  - username: wikijs
    password: wikijs
rights:
  - username: wikijs
    database: wikijs
```

Save the MariaDB add-on configuration and restart the MariaDB add-on. If you use
a different password, update the Wiki.js add-on option `DB_PASS` to the same
value before starting Wiki.js.

### Option 2: Manual SQL setup

Connect to MariaDB as an administrative user and create or repair the database
and user for Wiki.js:

```sql
CREATE DATABASE IF NOT EXISTS wikijs CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wikijs'@'%' IDENTIFIED BY 'wikijs';
ALTER USER 'wikijs'@'%' IDENTIFIED BY 'wikijs';
GRANT ALL PRIVILEGES ON wikijs.* TO 'wikijs'@'%';
FLUSH PRIVILEGES;
```

The user host must be `%` so the Wiki.js add-on container can connect from its
Docker network address, such as `172.30.x.x`.

If you still see `ER_ACCESS_DENIED_ERROR`, verify that the add-on options
`DB_NAME`, `DB_USER`, and `DB_PASS` exactly match the MariaDB database, login,
and rights configuration.

## Add-on options

```yaml
DB_HOST: core-mariadb
DB_PORT: 3306
DB_NAME: wikijs
DB_USER: wikijs
DB_PASS: wikijs
```

The add-on translates these options to Wiki.js environment variables and sets
`DB_TYPE=mysql`.

## Architecture notes

No aarch64 conflict was found with the official Wiki.js image. The
`ghcr.io/requarks/wiki:2` image is multi-arch and includes arm64 support.

The Dockerfile uses the official Wiki.js image as the runtime image and copies
`bashio` from `ghcr.io/home-assistant/aarch64-base` so Home Assistant add-on
options can be read without replacing Wiki.js' Node.js runtime and native
dependencies.