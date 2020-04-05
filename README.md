# Civtest Docker setup

Bundles all [Civtest](https://github.com/CivtestGame) mods with the modified server and a Postgres instance.

## Running the server

- Install git, Docker, and Docker-Compose ([instrunctions for Windows](https://docs.docker.com/docker-for-windows/)), and start the Docker daemon.
- Clone this repository recursively: `git clone --recursive git@github.com:Gjum/civtest-docker.git`
  This downloads the Civtest game, all the mods, and the custom server code.
- Run `docker-compose up`. This automatically builds the server, starts Postgres, and then starts the server.
- To stop the server and database, press <kbd>Ctrl+c</kbd>.

A new world will be created in `.minetest/worlds/world/`.

The Minetest config is located in `.minetest/minetest.conf`; the config inside `civtest_game/minetest.conf` is ignored.

Note that the server automatically restarts whenever it crashes.

To run the server in the background ("detached"), use: `docker-compose up -d`
Then, to stop it again, run: `docker-compose down`

## Updating mods

This repo comes with all Civtest mods preinstalled as [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).
To update all mods (and the server code), run `git pull --recurse-submodules -j8` from the repository root.
To update a single mod, `cd` into its directory and use the usual git commands: `git pull origin`, `git commit`, etc.

The mods are found in these two directories:

- `.minetest/games/civtest_game/mods/` - basic mods
- `.minetest/mods/` - database dependent mods

To keep the `civtest_game` repo runnable without a database, all database dependent mods are installed separately in `.minetest/mods/`.

If you update any mod inside `civtest_game`, make sure to also update its submodule in `civtest_game` and push its new version there too.

## Developing new mods

Create a new directory for your mod inside `.minetest/games/civtest_game/mods/` or `.minetest/mods/` (see above) and develop as usual.
When running the server with `docker-compose up` it will always run your latest code.

## Developing the server

Add the --build flag to tell Docker-Compose to rebuild your server:

`docker-compose up --build`

(This actually builds the whole Docker image, but most other parts of it will use the build cache.)
