var ShareExtensionClass = function() {};

ShareExtensionClass.prototype = {
    run: function(arguments) {
        arguments.completionFunction({ "currentUrl" : document.URL });
    },

    finalize: function(arguments) {
        var message = arguments["statusMessage"];
        alert("soy yooo");
        if (message) {
            alert(message);
        }
    }
    
};

var ExtensionPreprocessingJS = new ShareExtensionClass;