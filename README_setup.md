## Setup (VS Code)

The project can be setup with ease in VS Code. Open the project and install the recommended workspace extensions.

* Select the python version you want to use for the virtual environment: 

    * **Open the Command Palette**  Press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> (or <kbd>F1</kbd>) to open the Command Palette
    * Type `Python: Select Interpreter` and select the wanted python version

* Create the virtual environment:

   * **Open the Command Palette**
   * **Run Task** Type `Run Task` and select **Tasks: Run Task** from the dropdown
   * In the list of available tasks, choose **Create Python virtual environment**
   * When VS Code asks if you want to use the newly created environment, say **Yes**.

* Install build requirements:

   * **Open the Command Palette** -> **Run Task** -> Install requirements

Now you setup is completed.

For and editable installation of the python package:

* **Open the Command Palette** -> **Run Task** -> Editable Install [dev]

> **Note:**  
> The editable install part only works for the python code within your package. If you change something in C++ you have to recompile the extension