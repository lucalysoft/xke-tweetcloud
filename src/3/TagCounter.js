js_cols.require('js_cols.LinkedHashMap');
js_cols.require('js_cols.RedBlackMultiMap');

/**
 * Class that counts tag appearances in a stream.
 * Tags are removed in a LRU fashion from the counter.
 * 
 * @param {int=} maxSize the maximum size of the counter.
 * If more tags are added, the oldest tags are removed.
 */
function TagCounter(maxSize) {
	this.tagCounts = new js_cols.LinkedHashMap(maxSize, true);
};
/**
 * Adds a tag from the stream to this counter. 
 * @param tag The tag to add.
 */
TagCounter.prototype.add = function (tag) {
	if (this.tagCounts.contains(tag)) {
		this.tagCounts.insert(tag, this.tagCounts.get(tag) + 1);
	} else {
		this.tagCounts.insert(tag,1);
	}
};
/**
 * Returns the tags counted in an ordered map.
 * The keys in the map are the tags, the values are the number of appearances.
 * The result is ordered by number of appearances.
 * @param size_opt (optional) maximum size of the map returned, leaving of the tags with the least appearances.
 * @returns {js_cols.LinkedHashMap} A map from tag to number of appearances.
 */
TagCounter.prototype.map = function (opt_size) {
	var orderedMap = new js_cols.RedBlackMultiMap(function (a,b) {return b-a;});
	this.tagCounts.forEach(orderedMap.insert, orderedMap);
	var result = new js_cols.LinkedHashMap();
	if (opt_size) {
		var i = 0;
		orderedMap.forEach(function (value, key) {
			if (i < opt_size) {
				result.insert(value, key);
			}
			i++;
		});
	} else {
		orderedMap.forEach(result.insert, result);
	}
	return result;
};
