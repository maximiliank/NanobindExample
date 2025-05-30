## Build Instructions

### Enabling pre-commit hooks

You should enable pre-commit hooks. You can install pre-commit via

    pip install pre-commit

Then you can activate the hooks by running

    pre-commit install

If you want to run all hooks manually

    pre-commit run --all-files

You have to install codespell as well in your python environment.

### Build via cmake presets:

You can use one of the configuration presets that are listed in the CmakePresets.json file, e.g. unixlike-gcc-release,

    cmake . --preset <configure-preset>
    cmake --build out/build/<configure-preset> --target intro

Note that once we have setup build presets it should be possible to build with

	cmake --build --preset <build-preset> --target intro
