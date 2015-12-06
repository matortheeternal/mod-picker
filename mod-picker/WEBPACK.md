Setup
==

1. Install [NodeJS](http://nodejs.org)
2. Update npm with `npm install -g npm@latest` (prepend `sudo` for \*nix)
3. Navigate to the repo folder, then the `mod-picker/` directory
4. Run `npm install` to download all required libraries

Run
==

The build system wraps [webpack](https://webpack.github.io/) calls in npm scripts. So the only scripts you will need are:

1. `npm run build`
  - Compiles all javascript and scss files from `app/assets/src` to `app/assets/javascripts/bundle.js`
2. `npm run watch`
  - Runs `npm run build` then rebuilds when files are changed
  - Run this while developing so changes are automatically compiled into `bundle.js`
3. `npm run serve`
  - Runs `bin/rails server`, which starts the rails server at http://localhost:3000
3. `npm run spec`
  - Runs `karma start`, which runs unit tests and reruns them on file changes
