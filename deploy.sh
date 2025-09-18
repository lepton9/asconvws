#!/bin/bash

source .env.prod

mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

PHX_SERVER=true ./_build/prod/rel/asconvws/bin/asconvws start

