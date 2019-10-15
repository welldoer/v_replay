// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import net.urllib

fn test_net_urllib() {
	test_query := 'Hellö Wörld@vlang'
	assert urllib.query_escape(test_query) == 'Hell%C3%B6+W%C3%B6rld%40vlang'

	test_url := 'https://joe:pass@www.mydomain.com:8080/som/url?param1=test1&param2=test2&foo=bar#testfragment'
	u := urllib.parse(test_url) or {
		assert false
		return
	}
	assert u.scheme     == 'https' &&
		u.hostname()    == 'www.mydomain.com' &&
		u.port()        == '8080' &&
		u.path          == '/som/url' &&
		u.fragment      == 'testfragment' &&
		u.user.username == 'joe' && 
		u.user.password == 'pass'
}
