(function () {
    var folder = Folder.selectDialog("Select a folder containing SVG files");
    if (folder == null) {
        alert("No folder selected. Script cancelled.");
        return;
    }

    var svgFiles = folder.getFiles("*.svg");
    if (svgFiles.length === 0) {
        alert("No SVG files found in the selected folder.");
        return;
    }

    var exportFolder = new Folder(folder + "/ExportedPNGs");
    if (!exportFolder.exists) {
        exportFolder.create();
    }

    for (var i = 0; i < svgFiles.length; i++) {
        var doc = app.open(svgFiles[i]);

        // Resize artboard to fit 512x512
        var artboard = doc.artboards[0];
        artboard.artboardRect = [0, -512, 512, 0]; // Top-left (0,0), bottom-right (512, 512)

        // Prepare export file path
        var exportFile = new File(exportFolder + "/" + svgFiles[i].name.replace(".svg", ".png"));

        // PNG export options
        var exportOptions = new PNGSaveOptions();
        exportOptions.artBoardClipping = true;
        exportOptions.transparency = true; // Enable transparency
        exportOptions.horizontalScale = 100;
        exportOptions.verticalScale = 100;

        // Save as copy
        doc.saveAs(exportFile, exportOptions);
        doc.close(SaveOptions.DONOTSAVECHANGES);
    }

    alert("Export complete! PNGs saved to " + exportFolder.fsName);
})();
