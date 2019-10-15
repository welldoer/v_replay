const (
	q = [1, 2, 3]
	A = 8
)

fn test_ints() {
	mut a := [1, 5, 2, 3]
	assert a.len == 4
	assert a[0] == 1
	assert a[2] == 2
	assert a.last() == 3
	a << 4
	assert a.len == 5
	assert a[4] == 4
	assert a.last() == 4

	s := a.str()
	assert s == '[1, 5, 2, 3, 4]'
	assert a[1] == 5
	assert a.last() == 4
}

fn test_deleting() {
	mut a := [1, 5, 2, 3, 4]
	assert a.len == 5
	assert a.str() == '[1, 5, 2, 3, 4]'

	a.delete(0)
	assert a.str() == '[5, 2, 3, 4]'
	assert a.len == 4

	a.delete(1)
	assert a.str() == '[5, 3, 4]'
	assert a.len == 3
}

fn test_short() {
	a := [1, 2, 3]
	assert a.len == 3
	assert a.cap == 3
	assert a[0] == 1
	assert a[1] == 2
	assert a[2] == 3
}

fn test_large() {
	mut a := [0].repeat(0)
	for i := 0; i < 10000; i++ {
		a << i
	}
	assert a.len == 10000
	assert a[234] == 234
}

struct Chunk {
	val string
}

struct K {
	q []Chunk
}

fn test_empty() {
	mut chunks := []Chunk{}
	a := Chunk{}
	assert chunks.len == 0
	chunks << a
	assert chunks.len == 1
	chunks = []Chunk{}
	assert chunks.len == 0
	chunks << a
	assert chunks.len == 1
}

fn test_push() {
	mut a := []int
	a << 1
	a << 3
	assert a[1] == 3
	assert a.str() == '[1, 3]'
}

fn test_strings() {
	a := ['a', 'b', 'c']
	assert a.str() == '["a", "b", "c"]'
}

fn test_repeat() {
	a := [0].repeat(5)
	assert a.len == 5
	assert a[0] == 0 && a[1] == 0 && a[2] == 0 && a[3] == 0 && a[4] == 0

	b := [7].repeat(3)
	assert b.len == 3
	assert b[0] == 7 && b[1] == 7 && b[2] == 7
	{
		mut aa := [1.1].repeat(10)
		// FIXME: assert aa[0] == 1.1 will fail, need fix
		assert aa[0] == f32(1.1)
		assert aa[5] == f32(1.1)
		assert aa[9] == f32(1.1)
	}
	{
		mut aa := [f32(1.1)].repeat(10)
		assert aa[0] == f32(1.1)
		assert aa[5] == f32(1.1)
		assert aa[9] == f32(1.1)
	}
	{
		aa := [f64(1.1)].repeat(10)
		assert aa[0] == f64(1.1)
		assert aa[5] == f64(1.1)
		assert aa[9] == f64(1.1)
	}
}

fn test_right() {
	a := [1, 2, 3, 4]
	b := a.right(1)
	assert b[0] == 2
	assert b[1] == 3
}

fn test_left() {
	a := [1, 2, 3]
	b := a.left(2)
	assert b[0] == 1
	assert b[1] == 2
}

fn test_slice() {
	a := [1, 2, 3, 4]
	b := a.slice(2, 4)
	assert b.len == 2
	assert a.slice(1, 2).len == 1
	assert a.len == 4
}

fn test_push_many() {
	mut a := [1, 2, 3]
	b := [4, 5, 6]
	a << b
	assert a.len == 6
	assert a[0] == 1
	assert a[3] == 4
	assert a[5] == 6
}

fn test_reverse() {
  mut a := [1, 2, 3, 4]
	mut b := ['test', 'array', 'reverse']
	c := a.reverse()
	d := b.reverse()
	for i, _  in c {
		assert c[i] == a[a.len-i-1]
	}
	for i, _ in d {
		assert d[i] == b[b.len-i-1]
	}
}

const (
	N = 5
)

fn test_fixed() {
	mut nums := [4]int
	assert nums[0] == 0
	assert nums[1] == 0
	assert nums[2] == 0
	assert nums[3] == 0
	nums[1] = 7
	assert nums[1] == 7
	nums2 := [N]int
	assert nums2[N - 1] == 0
}

fn modify (numbers mut []int) {
        numbers[0] = 777
}

fn test_mut_slice() {
	mut n := [1,2,3]
	modify(mut n.left(2))
	assert n[0] == 777
	modify(mut n.right(2))
	assert n[2] == 777
	println(n)
}

fn test_clone() {
	nums := [1, 2, 3, 4, 100]
	nums2 := nums.clone()
	assert nums2.len == 5
	assert nums2.str() == '[1, 2, 3, 4, 100]'
	assert nums.slice(1, 3).str() == '[2, 3]'
}

fn test_doubling() {
	mut nums := [1, 2, 3, 4, 5]
	for i := 0; i < nums.len; i++ {
		nums[i] *= 2
	}
	assert nums.str() == '[2, 4, 6, 8, 10]'
}

struct Test2 {
	one int
	two int
}

struct Test {
	a string
mut:
	b []Test2
}

fn (t Test2) str() string {
	return '{$t.one $t.two}'
}

fn (t Test) str() string {
	return '{$t.a $t.b}'
}

fn test_struct_print() {
	mut a := Test {
		a: 'Test',
		b: []Test2
	}
	b := Test2 {
		one: 1,
		two: 2
	}
	a.b << b
	a.b << b
	assert a.str() == '{Test [{1 2}, {1 2}] }'
	assert b.str() == '{1 2}'
	assert a.b.str() == '[{1 2}, {1 2}]'
}

fn test_single_element() {
	mut a := [1]
	a << 2
	assert a.len == 2
	assert a[0] == 1
	assert a[1] == 2
	println(a)
}	

fn test_find_index() {
	// string
	a := ['v', 'is', 'great']
	assert a.index('v') == 0
	assert a.index('is') == 1
	assert a.index('gre')  == -1

	// int
	b := [1, 2, 3, 4]
	assert b.index(1) == 0
	assert b.index(4) == 3
	assert b.index(5) == -1

	// byte
	c := [0x22, 0x33, 0x55]
	assert c.index(0x22) == 0
	assert c.index(0x55) == 2
	assert c.index(0x99) == -1

	// char
	d := [`a`, `b`, `c`]
	assert d.index(`b`) == 1
	assert d.index(`c`) == 2
	assert d.index(`u`) == -1
}

fn test_multi() {
	a := [[1,2,3],[4,5,6]]
	assert a.len == 2
	assert a[0].len == 3
	assert a[0][0] == 1
	assert a[0][2] == 3
	assert a[1][2] == 6
	// TODO
	//b :=  [ [[1,2,3],[4,5,6]], [[1,2]] ]
	//assert b[0][0][0] == 1
}

fn test_in() {
	a := [1,2,3]
	assert 1 in a
	assert 2 in a
	assert 3 in a
	assert !(4 in a)
	assert !(0 in a)
}

fn callback_1(val int, index int, arr []int) bool {
	return val >= 2
}

fn callback_2(val string, index int, arr []string) bool {
	return val.len >= 2
}

fn test_filter() {
	a := [1, 2, 3, 4, 5, 6]
	b := a.filter(callback_1)
	assert b[0] == 2
	assert b[1] == 3

	c := ['v', 'is', 'awesome']
	d := c.filter(callback_2)
	assert d[0] == 'is'
	assert d[1] == 'awesome'
}

fn sum(prev int, curr int) int {
	return prev + curr
}

fn sub(prev int, curr int) int {
	return prev - curr
}

fn test_reduce() {
	a := [1, 2, 3, 4, 5]
	b := a.reduce(sum, 0)
	c := a.reduce(sum, 5)
	d := a.reduce(sum, -1)
	assert b == 15
	assert c == 20
	assert d == 14

	e := [1, 2, 3]
	f := e.reduce(sub, 0)
	g := e.reduce(sub, -1)
	assert f == -6
	assert g == -7
}
