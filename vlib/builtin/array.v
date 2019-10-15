// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module builtin

import strings

struct array {
pub:
	// Using a void pointer allows to implement arrays without generics and without generating
	// extra code for every type.
	data         voidptr
	len          int
	cap          int
	element_size int
}

// Private function, used by V (`nums := []int`)
fn new_array(mylen, cap, elm_size int) array {
	arr := array {
		len: mylen
		cap: cap
		element_size: elm_size
		data: calloc(cap * elm_size)
	}
	return arr
}


// TODO
pub fn make(len, cap, elm_size int) array {
	return new_array(len, cap, elm_size)
}


// Private function, used by V (`nums := [1, 2, 3]`)
fn new_array_from_c_array(len, cap, elm_size int, c_array voidptr) array {
	arr := array {
		len: len
		cap: cap
		element_size: elm_size
		data: calloc(cap * elm_size)
	}
	// TODO Write all memory functions (like memcpy) in V
	C.memcpy(arr.data, c_array, len * elm_size)
	return arr
}

// Private function, used by V (`nums := [1, 2, 3] !`)
fn new_array_from_c_array_no_alloc(len, cap, elm_size int, c_array voidptr) array {
	arr := array {
		len: len
		cap: cap
		element_size: elm_size
		data: c_array
	}
	return arr
}

// Private function, used by V  (`[0; 100]`)
fn array_repeat_old(val voidptr, nr_repeats, elm_size int) array {
	arr := array {
		len: nr_repeats
		cap: nr_repeats
		element_size: elm_size
		data: calloc(nr_repeats * elm_size)
	}
	for i := 0; i < nr_repeats; i++ {
		C.memcpy(arr.data + i * elm_size, val, elm_size)
	}
	return arr
}

pub fn (a array) repeat(nr_repeats int) array {
	arr := array {
		len: nr_repeats
		cap: nr_repeats
		element_size: a.element_size
		data: calloc(nr_repeats * a.element_size)
	}
	val := a.data + 0 //nr_repeats * a.element_size
	for i := 0; i < nr_repeats; i++ {
		C.memcpy(arr.data + i * a.element_size, val, a.element_size)
	}
	return arr
}

pub fn (a mut array) sort_with_compare(compare voidptr) {
	C.qsort(a.data, a.len, a.element_size, compare)
}

pub fn (a mut array) insert(i int, val voidptr) {
	if i >= a.len {
		panic('array.insert: index larger than length')
	}
	a.push(val)
	size := a.element_size
	C.memmove(a.data + (i + 1) * size, a.data + i * size, (a.len - i) * size)
	a.set(i, val)
}

pub fn (a mut array) prepend(val voidptr) {
	a.insert(0, val)
}

pub fn (a mut array) delete(idx int) {
	size := a.element_size
	C.memmove(a.data + idx * size, a.data + (idx + 1) * size, (a.len - idx) * size)
	a.len--
	a.cap--
}

fn (a array) get(i int) voidptr {
	if i < 0 || i >= a.len {
		panic('array index out of range: $i/$a.len')
	}
	return a.data + i * a.element_size
}

pub fn (a array) first() voidptr {
	if a.len == 0 {
		panic('array.first: empty array')
	}
	return a.data + 0
}

pub fn (a array) last() voidptr {
	if a.len == 0 {
		panic('array.last: empty array')
	}
	return a.data + (a.len - 1) * a.element_size
}

pub fn (s array) left(n int) array {
	if n >= s.len {
		return s
	}
	return s.slice(0, n)
}

pub fn (s array) right(n int) array {
	if n >= s.len {
		return s
	}
	return s.slice(n, s.len)
}

pub fn (s array) slice(start, _end int) array {
	mut end := _end
	if start > end {
		panic('invalid slice index: $start > $end')
	}
	if end > s.len {
		panic('runtime error: slice bounds out of range ($end >= $s.len)')
	}
	if start < 0 {
		panic('runtime error: slice bounds out of range ($start < 0)')
	}
	l := end - start
	res := array {
		element_size: s.element_size
		data: s.data + start * s.element_size
		len: l
		cap: l
		//is_slice: true
	}
	return res
}

fn (a mut array) set(idx int, val voidptr) {
	if idx < 0 || idx >= a.len {
		panic('array index out of range: $idx / $a.len')
	}
	C.memcpy(a.data + a.element_size * idx, val, a.element_size)
}

fn (arr mut array) push(val voidptr) {
	if arr.len >= arr.cap - 1 {
		cap := (arr.len + 1) * 2
		// println('_push: realloc, new cap=$cap')
		if arr.cap == 0 {
			arr.data = calloc(cap * arr.element_size)
		}
		else {
			arr.data = C.realloc(arr.data, cap * arr.element_size)
		}
		arr.cap = cap
	}
	C.memcpy(arr.data + arr.element_size * arr.len, val, arr.element_size)
	arr.len++
}

// `val` is array.data
// TODO make private, right now it's used by strings.Builder
pub fn (arr mut array) push_many(val voidptr, size int) {
	if arr.len >= arr.cap - size {
		cap := (arr.len + size) * 2
		// println('_push: realloc, new cap=$cap')
		if arr.cap == 0 {
			arr.data = calloc(cap * arr.element_size)
		}
		else {
			arr.data = C.realloc(arr.data, cap * arr.element_size)
		}
		arr.cap = cap
	}
	C.memcpy(arr.data + arr.element_size * arr.len, val, arr.element_size * size)
	arr.len += size
}

pub fn (a array) reverse() array {
	arr := array {
		len: a.len
		cap: a.cap
		element_size: a.element_size
		data: calloc(a.cap * a.element_size)
	}
	for i := 0; i < a.len; i++ {
		C.memcpy(arr.data + i * arr.element_size, &a[a.len-1-i], arr.element_size)
	}
	return arr
}

pub fn (a array) clone() array {
	arr := array {
		len: a.len
		cap: a.cap
		element_size: a.element_size
		data: calloc(a.cap * a.element_size)
	}
	C.memcpy(arr.data, a.data, a.cap * a.element_size)
	return arr
}

//pub fn (a []int) free() {
pub fn (a array) free() {
	//if a.is_slice {
		//return
	//}
	C.free(a.data)
}

// "[ 'a', 'b', 'c' ]"
pub fn (a []string) str() string {
	mut sb := strings.new_builder(a.len * 3)
	sb.write('[')
	for i := 0; i < a.len; i++ {
		val := a[i]
		sb.write('"')
		sb.write(val)
		sb.write('"')
		if i < a.len - 1 {
			sb.write(', ')
		}
	}
	sb.write(']')
	return sb.str()
}

pub fn (b []byte) hex() string {
	mut hex := malloc(b.len*2+1)
	mut ptr := &hex[0]
	for i := 0; i < b.len ; i++ {
		ptr += C.sprintf(*char(ptr), '%02x', b[i])
	}
	return string(hex)
}

// TODO: implement for all types
pub fn copy(dst, src []byte) int {
	if dst.len > 0 && src.len > 0 {
		min := if dst.len < src.len { dst.len } else { src.len }
		C.memcpy(dst.data, src.left(min).data, dst.element_size*min)
		return min
	}
	return 0
}

fn compare_ints(a, b &int) int {
	if a < b {
		return -1
	}
	if a > b {
		return 1
	}
	return 0
}

pub fn (a mut []int) sort() {
	a.sort_with_compare(compare_ints)
}

// Looking for an array index based on value.
// If there is, it will return the index and if not, it will return `-1`
pub fn (a []string) index(v string) int {
	for i := 0; i < a.len; i++ {
		if a[i] == v {
			return i
		}
	}
	return -1
}

pub fn (a []int) index(v int) int {
	for i := 0; i < a.len; i++ {
		if a[i] == v {
			return i
		}
	}
	return -1
}

pub fn (a []byte) index(v byte) int {
	for i := 0; i < a.len; i++ {
		if a[i] == v {
			return i
		}
	}
	return -1
}

pub fn (a []char) index(v char) int {
	for i := 0; i < a.len; i++ {
		if a[i] == v {
			return i
		}
	}
	return -1
}

////////////// FILTER //////////////

// Creates a new array with all elements that pass the test implemented by the provided function.
pub fn (a  []string) filter(predicate fn(p_val string, p_i int, p_arr []string) bool) []string
{
	mut res := []string
	for i := 0; i < a.len; i++  {
		if predicate(a[i], i, a) {
			res << a[i]
		}
	}
	return res
}

pub fn (a []int) filter(predicate fn(p_val, p_i int, p_arr []int) bool) []int
{
	mut res := []int
	for i := 0; i < a.len; i++  {
		if predicate(a[i], i, a) {
			res << a[i]
		}
	}
	return res
}

////////////// REDUCE //////////////

// Executes a reducer function (that you provide) on each element of the array, 
// resulting in a single output value.
pub fn (a []int) reduce(iter fn (accum, curr int) int, accum_start int) int {
	mut _accum := 0
	_accum = accum_start
	for i := 0; i < a.len; i++ {
			_accum = iter(_accum, a[i])
	}
	return _accum
}
