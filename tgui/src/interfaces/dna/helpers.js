module.exports.DNABlocks = function DNABlocks (DNA) {
	var blocks = [];
	for (var i = 0; i < DNA.length; i++) {
		blocks.push([DNA.charAt(i), DNA.charAt(++i), DNA.charAt(++i)]);
	}
	return blocks;
}
