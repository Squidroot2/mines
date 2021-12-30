extends Node

# Contains 0-9, A-Z, and a-z
var ALPHA_NUMERIC_CHARACTERS: Array = range(48,58)+range(65,91)+range(97,123)

func generate_random_string(max_size: int, min_size: int, include_symbols=false) -> String:
	var outstring: String = ""
	
	var length: int = randi() % (max_size + 1 - min_size) + min_size
	
	if include_symbols:
		for _i in range(length):
			# 32 (UTF+20) is space, the first valid character, goes to 126 (UTF+7e) aka ~. Diff is 94
			var rand_char : int = randi() % 94 + 32
			outstring += char(rand_char)
	
	else:
		for _i in range(length):
			var rand_index: int = randi() % ALPHA_NUMERIC_CHARACTERS.size()
			outstring += char(ALPHA_NUMERIC_CHARACTERS[rand_index])
	
	return outstring

func string_to_seed(from: String) -> int:
	var bytes: PoolByteArray = from.sha1_buffer()
	bytes.resize(8)
	var out: int = 0
	out += bytes[0]
	out += bytes[1]*256
	out += bytes[2]*65536
	out += bytes[3]*16777216
	out += bytes[4]*4294967296
	out += bytes[5]*1099511627776
	out += bytes[6]*281474976710656
	out += (bytes[7]%128)*36028797018963968
	if bytes[7] >127:
		out *= -1
	return out
	
