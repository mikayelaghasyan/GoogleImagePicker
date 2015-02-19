var nodesPath = [];
var rootNode = null;

function gipInit() {
	gipInitImageContainer();
	gipHideRedundantNodes();
	gipInitLinkCaptures();
	gipInitObserver();
}

function gipInitImageContainer() {
	rootNode = document.getElementById("rg_s");
	while (rootNode.parentNode != null) {
		nodesPath[nodesPath.length] = rootNode;
		rootNode = rootNode.parentNode;
		if (rootNode == document.body) {
			break;
		}
	}
}

function gipHideRedundantNodes() {
	if (gipIsImageContainerInitialized()) {
		gipHideChildNodes(rootNode);
	}
}

function gipInitLinkCaptures() {
	var containerNode = document.getElementById("rg_s");
	for (var i = 0; i < containerNode.childNodes.length; i++) {
		var child = containerNode.childNodes[i];
		if (child.nodeType == 1 && child.nodeName.toLowerCase() == "div") {
			child.onclick = gipImageClicked;
			gipRemoveLinks(child);
		}
	}
}

function gipRemoveLinks(node) {
	var childNodes = null;
	if (node.nodeName.toLowerCase() == "a") {
		childNodes = node.childNodes;
	} else {
		for (var i = 0; i < node.childNodes.length; i++) {
			var child = node.childNodes[i];
			var nodeList = gipRemoveLinks(child);
			if (nodeList != null) {
				for (var j = 0; j < nodeList.length; j++) {
					node.insertBefore(nodeList[j], child);
				}
				var imageInfo = gipExtractImageInfo(child.href);
				if (imageInfo) {
					if (imageInfo["URL"]) {
						node.gipImageURL = imageInfo["URL"];
					}
					if (imageInfo["width"]) {
						node.gipImageWidth = imageInfo["width"];
					}
					if (imageInfo["height"]) {
						node.gipImageHeight = imageInfo["height"];
					}
				}
				node.removeChild(child);
			}
		}
	}
	return childNodes;
}

function gipInitObserver() {
	var observer = new MutationObserver(gipMutationObserverCallback);
	var config = { attributes: true, childList: true, characterData: true };
	observer.observe(document.getElementById("rg_s"), config);
}

function gipIsImageContainerInitialized() {
	return (rootNode != null);
}

function gipHideChildNodes(node) {
	for (var i = 0; i < node.childNodes.length; i++) {
		var child = node.childNodes[i];
		if (child.nodeType == 1) {
			var idx = nodesPath.indexOf(child);
			if (idx == -1) {
				child.style.display = "none";
			} else if (idx > 0) {
				gipHideChildNodes(child);
			}
		}
	}
}

function gipExtractImageInfo(href) {
	var imageInfo = {};
	var parts = href.split("?");
	if (parts.length > 1) {
		var params = parts[1].split("#")[0].split("&");
		for (var i = 0; i < params.length; i++) {
			param = params[i];
			var paramParts = param.split("=");
			if (paramParts.length > 1) {
				if (paramParts[0] == "imgurl") {
					imageInfo["URL"] = paramParts[1];
				} else if (paramParts[0] == "w") {
					imageInfo["width"] = paramParts[1];
				} else if (paramParts[0] == "h") {
					imageInfo["height"] = paramParts[1];
				}
			}
		}
	}
	return imageInfo;
}

function gipMutationObserverCallback(mutations) {
	gipHideRedundantNodes();
	gipInitLinkCaptures();
}

function gipImageClicked(e) {
	if (e.currentTarget.gipImageURL) {
		var loc = "gip:" + encodeURIComponent(e.currentTarget.gipImageURL);
		if (e.currentTarget.gipImageWidth) {
			loc += ":" + encodeURIComponent(e.currentTarget.gipImageWidth);
		}
		if (e.currentTarget.gipImageHeight) {
			loc += ":" + encodeURIComponent(e.currentTarget.gipImageHeight);
		}
		window.location = loc;
	}
}

gipInit();