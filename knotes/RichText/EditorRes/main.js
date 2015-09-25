window.onload = function() {
    rangy.init()

    var serialize   = document.getElementById("serialize")
      , removeh1    = document.getElementById("removeh1")
      , highlight   = document.getElementById("highlight")
      , buffer      = document.getElementById("buffer").children[0].children[0]
      , hlapplier   = rangy.createCssClassApplier("highlight");
    
    removeh1.addEventListener("click", function() {
        document.getElementsByTagName("h1")[0].remove();
        removeh1.disabled = true;
    });
    
    serialize.addEventListener("click", function() {
        if (rangy.getSelection().isCollapsed) return;
        var serializedSelection = rangy.serializeSelection(rangy.getSelection(), true);
        buffer.value = serializedSelection;
    });
    
    highlight.addEventListener("click", function() {
        var serializedSelection = buffer.value;

        if (!serializedSelection) return;

        try {
            rangy.deserializeSelection(serializedSelection);
            hlapplier.toggleSelection();
        } catch (e) {
            var text         = "has no child with index"
              , rangeinvalid = e.message.indexOf(text) > -1;

            if (rangeinvalid) alert("页面内容已改变，无法恢复选区高亮!");
        }

        rangy.getSelection().collapseToEnd();
    });
}
