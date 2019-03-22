# svg_to_kicad
A simple processing sketch to convert svg files to kicad footprints.

Importing complex shapes as kicad components is always painful, I made this tool to try to smoothen the process.

The gui allows you to:
- Choose which svg file to open
- View the svg file and zoom in/out
- Visualize the points of the resilting path
- Select a folder where to export the component
- Export the svg to kicad.mod file


Still some work need to be done :) contributions are very welcomed
TODO:
- [ ] Add toggle to switch between front/back silk
- [ ] Improve export of shapes with cutout parts
- [ ] check that the exported footprints have the same size of the imported one
- [ ] improve zoom mechanism
