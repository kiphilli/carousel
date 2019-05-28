/**
 * Created by Robert on 12/11/2017.
 */
({
    updateVideoAttributes : function(component){
        var iVid = component.find("iframeVideo");

        if(!$A.util.isUndefinedOrNull(iVid)){
            var iVidElem = iVid.getElement();
            iVidElem.setAttribute("allowfullscreen", "allowfullscreen");
            iVidElem.setAttribute("webkitallowfullscreen", "webkitallowfullscreen");
            iVidElem.setAttribute("mozallowfullscreen", "mozallowfullscreen");
        }
    }
})