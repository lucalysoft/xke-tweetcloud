/**
 * Unit Tests for TagCounter
 */
YUI({
  combine: true,
  timeout: 10000
}).use("node", "console", "test", function (Y) {
  var assert = Y.Assert;

  var TagCounterTestCase = new Y.Test.Case({
    // test case name - if not provided, one is generated
    name: "TagCounter Tests",

    "test should increment count": function () {
      var tc = new TagCounter(2);
      tc.add("my-tag");
      assertSame(tc.map(), [["my-tag", 1]]);
      tc.add("my-tag");
      assertSame(tc.map(), [["my-tag", 2]]);
    },
    "test should increment count with multiple items": function () {
        var tc = new TagCounter(2);
        tc.add("my-tag");
        assertSame(tc.map(), [["my-tag", 1]]);
        tc.add("my-other-tag");
        assertSame(tc.map(), [["my-other-tag", 1],["my-tag", 1]]);
        tc.add("my-tag");
        assertSame(tc.map(), [["my-tag", 2],["my-other-tag", 1]]);
    },
    "test should remove LRU": function () {
    	var tc = new TagCounter(2);
    	tc.add("my-old-tag");
    	tc.add("my-old-tag");
    	tc.add("my-old-tag");
    	assertSame(tc.map(), [["my-old-tag", 3]]);
    	tc.add("my-first-tag");
    	tc.add("my-first-tag");
    	assertSame(tc.map(), [["my-old-tag", 3], ["my-first-tag", 2]]);    	
    	tc.add("my-second-tag");
    	assertSame(tc.map(), [["my-first-tag", 2], ["my-second-tag", 1]]);    	
    },
    "test should return limited sized map": function () {
    	var tc = new TagCounter(3);
    	tc.add("my-old-tag");
    	tc.add("my-old-tag");
    	tc.add("my-old-tag");
    	assertSame(tc.map(2), [["my-old-tag", 3]]);
    	tc.add("my-first-tag");
    	tc.add("my-first-tag");
    	assertSame(tc.map(2), [["my-old-tag", 3], ["my-first-tag", 2]]);    	
    	tc.add("my-second-tag");
    	assertSame(tc.map(2), [["my-old-tag", 3], ["my-first-tag", 2]]);    	
    	tc.add("my-third-tag");
    	assertSame(tc.map(2), [["my-first-tag", 2], ["my-third-tag", 1]]);    	
    }
  });
  
  function assertSame(map, expected) {
	  var keys = map.getKeys();
	  assert.areEqual(expected.length, keys.length);
	  for(var i=0,len=expected.length; value=expected[i], i<len; i++) {
		  assert.areEqual(value[0], keys[i]);
		  assert.areEqual(value[1], map.get(value[0]));
	  }
  };
  
  //create the console
  var r = new Y.Console({
    newestOnTop : false,
    style: 'block'
  });

  r.render("#testReport");
  Y.Test.Runner.add(TagCounterTestCase);
  Y.Test.Runner.run();
});