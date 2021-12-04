// I have javascript, especially this broke-ass edition of it. - N3X

const MAX_WORDS = 30;

let $errPane = null;
let $resetButton = null;
let $submitButton = null;
let $wordlen = null;
let $words = null;

function addError(message) {
	$errPane.append($('<li>').text(message));
}

function validate() {
	let v = $words.val();
	// Clear previous errors.
	$errPane.html('');

	// Make sure there's SOMETHING in the textbox.
	if(v.length <= 0) {
		// Update wordcount.
		$wordlen.text("0/"+MAX_WORDS.toString());
		$wordlen.css('color', '#ff0000');
		// Throw error.
		addError('Empty field.');
		return false;
	}

	let words = v.split(' ');
	let word = '';
	let errored = false;
	let i=0;
	// Get rid of zero-length entries in the wordlist.
	// effectively words=words.filter(word => word.length > 0);
	// but LOL IE8
	let nuwords = [];
	for(i=0;i<words.length;i++) {
		word = words[i];
		if(word.length > 0)
			nuwords.push(word);
	}
	words = nuwords;

	// Update word counter
	$wordlen.text(words.length.toString()+"/"+MAX_WORDS.toString());
	$wordlen.css('color', (words.length > 0 && words.length < MAX_WORDS) ? '#cccccc' : '#ff0000');

	// Check word count
	if(words.length < 1) {
		addError('At least one word is required.');
		return false;
	}
	if(words.length > MAX_WORDS) {
		addError('Too many words, maximum is '+MAX_WORDS.toString()+'.');
		return false;
	}

	// Check if the words are in our list.
	for(i=0;i<words.length;i++) {
		word=words[i];
		// God I wish we had `in`
		if(window.availableWords.indexOf(word) === -1){
			addError("Word \""+word+"\" does not exist in the voicepack. Use another word.");
			errored = true;
		}
	}
	return !errored;
}

// Once the document initializes...
$(document).ready(function() {
	// Hook into all our needed elements.
	$errPane = $('#errors');
	$submitButton = $('#submit');
	$resetButton = $('#reset');
	$wordlen = $('#wordcount');
	// Set up autocomplete
	$words = $( "#words" ).autocomplete({
		lookup: window.availableWords,
		delimiter: ' ',
		onSelect: function(a) {
			$submitButton.prop('disabled', !validate());
		}
	}).keyup(function(e){
		$submitButton.prop('disabled', !validate());
	});
	$submitButton.click(function(e) {
		let words = $words.val().split(' ');
		// Get rid of zero-length entries in the wordlist.
		// effectively words=words.filter(word => word.length > 0);
		// but LOL IE8
		let nuwords = [];
		for(i=0;i<words.length;i++) {
			word = words[i];
			if(word.length > 0)
				nuwords.push(word);
		}
		words = nuwords;
		if(validate()) {
			window.location = "?src="+airef+";play_announcement="+words.join('+');
		}
	});
	$resetButton.click(function(e) {
		$words.val('');
		validate();
	});
	$submitButton.prop('disabled', !validate());
});
