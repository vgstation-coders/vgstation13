/* ==== HREF MULTIPART HANDLER ====
 *
 * For situations where your Topic() link exceeds the browser's ~2000 character limit and ends up ignored.
 *
 * Import this file in your UI's headers. Leave your link's href empty, instead have it pass the object's reference (the "src=" parameter)
 *  and your parameters to 'HREFmultipartHandler(topicSrc, rawContent)'.
 * An example might look like this:
 *
 *  	<a onclick='HREFmultipartHandler(src, "foo=aaaa...aaaa;bar=aaaa...aaaa");'
 *
 * The object that'll handle the Topic() should have an href_multipart_handler, and redirect multipart requests ('multipart=1' parameter) towards
 *  said handler's Topic (See '/code/modules/html_interface/href_multipart_handler.dm' for more info).
 *
 * == How it works ==
 * Your parameter string is percent encoded, and split into 'N' pieces, each at most 'MULTIPART_PART_SIZE' characters (that is, less than 2000 characters).
 *
 * Each piece is sent as an individual request (simulating clincking a link), alongside with the following parameters:
 * - src: As with all Topic() links, specifies the object that'll handle the request
 * - multipart: Specifies that this is a multipart request. Will always be '1'
 * - multipart-total: Specifies how many parts to expect ('N' pieces)
 * - multipart-number: Specifies which part this is, so that all parts may be reassembled in order
 * - multipart-content: The actual payload, percent encoded. The parameters you were trying to send but had to be sliced up.
*/



/* Limit is specified at 2048 characters (http://support.microsoft.com/kb/208427), base multipart link will usually be at least ~84 characters.
 * 1900 should provides leeway for 32 digit part requests. WAY more than enough, hopefully
 */
const MULTIPART_PART_SIZE = 1900;

function HREFmultipartHandler(topicSrc, rawContent) {
	//Sanitize our payload and calculate how many parts will be needed
	var content = encodeURIComponent(rawContent);
	var totalParts = Math.ceil(content.length/MULTIPART_PART_SIZE);

	//Prepare the href's parameters
	var baseMultipartParams = "?src=" + topicSrc + ";multipart=1;multipart-total=" + totalParts + ";multipart-number=";

	//Slice the content into parts and send each part
	for (var part = 0; part < totalParts; part++) {
		var contentPart = content.slice(MULTIPART_PART_SIZE * part, MULTIPART_PART_SIZE * (part + 1));
		window.location.href = baseMultipartParams + (part + 1) + ";multipart-content=" + contentPart;
	}
}
