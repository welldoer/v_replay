
import rand
import time

fn gen_randoms(seed i64, bound int) []u64 {
	mut randoms := [u64(0)].repeat(20)
	mut rnd := rand.new_splitmix64( u64(seed) )
	for i in 0..20 {
		randoms[i] = rnd.bounded_next(u64(bound))
	}
	return randoms
}

fn test_splitmix64_reproducibility() {
	t := time.ticks()
	println('t: $t')
	randoms1 := gen_randoms(t, 1000)
	randoms2 := gen_randoms(t, 1000)
	assert randoms1.len == randoms2.len
	println( randoms1 )
	println( randoms2 )
	len := randoms1.len
	for i in 0..len {
		assert randoms1[i] == randoms2[i]
	}	
}
