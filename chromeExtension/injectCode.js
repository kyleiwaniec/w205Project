console.debug("getting page links...")
//var pageLinks = document.querySelectorAll('a');
var pageLinks = document.links; // typeof document.links is object. do not use for loop
var linksTable = {};
var links_array = Array.prototype.slice.call(pageLinks);
links_array.map(function(link){
	linksTable[link.getAttribute('href')] = link.getAttribute('href') // table where keys are links for fast lookup
})


function getData(callback){
	var xhr = new XMLHttpRequest();

	// todo: remember to enable CORS
	var url = 'https://w205twitterproject.s3-us-west-2.amazonaws.com/links2.json';

	xhr.open('GET', url);
	xhr.responseType = 'json'; // if we do json
	xhr.onload = function() {
	    if (xhr.status === 200) {
	    	//var links = xhr.responseText; // if we do txt

	        console.debug('response', xhr.response);
	        console.debug('successfully fetched links')
	        var links = xhr.response.links;
	        // mock response for testing on https://groups.google.com/forum/?hl=en#!forum/beets-users:
	        locallinks = [{"link":"#!topic/beets-users/axSjca_Tk9c"},
	        		{"link":"https://www.google.com/intl/en/options/"},
					{"link":"https://myaccount.google.com/?utm_source=OGB&authuser=1"},
					{"link":"https://www.google.com/webhp?tab=gw&authuser=1&ei=WWVYVtiJM4LSmwHgsbzQAQ&ved=0EKkuCAQoAQ"},
					{"link":"https://plus.google.com/u/1/?tab=gX"},
					{"link":"https://mail.google.com/mail/?tab=gm&authuser=1"},
					{"link":"https://www.google.com/calendar?tab=gc&authuser=1"}
					];

	        var morelinks = links.concat(locallinks)
	        callback(morelinks);
	    }
	    else {
	        console.debug('Request failed.  Returned status of ' + xhr.status);
	    }
	};
	xhr.send();
}

function highlight(spamLinks) {
	console.debug("highlighting")
    // just the filtered links: minimize DOM manipulation.
    var filteredLinks = filter(linksTable, spamLinks);

    for(var i = 0,l = filteredLinks.length; i < l; i++) {
    	var link = document.querySelector('a[href="'+filteredLinks[i]+'"]');
    	link.style.backgroundColor = '#FF0';
	    link.style.color = '#000';
	}

    console.debug("all done thnks")
}

function filter(pageLinks, spamLinks){
	console.debug("filtering")
	var collection = [];
	for(i=0, l=spamLinks.length;i<l;i++){
		if(linksTable[spamLinks[i]['tco']]){
			collection.push(spamLinks[i]['tco'])
		}
		if(linksTable[spamLinks[i]['link']]){
			collection.push(spamLinks[i]['link'])
		}
	}
	console.debug('collection', collection)
	return collection;
}


getData(highlight)
