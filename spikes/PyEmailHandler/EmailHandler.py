import sys
import os

def fix_email(s):
	if s.find("<") > -1:
		return s[s.find("<")+1:s.find(">")]
	else:
		return s

def load_emails(filename):
	a = map(str.strip, open(filename, 'r').read().split(','))
	return map(fix_email, a)

# load current and new emails into arrays
current_emails = load_emails("current.txt")
new_emails = load_emails("new.txt")

# get different emails
diff_emails = set(new_emails) - set(current_emails)
output_str = ', \r\n'.join(diff_emails)

# clear output if it exists
output_filename = './output.txt'
if os.path.isfile(output_filename):
	os.remove(output_filename)

# write to output
output = open('./output.txt', 'a')
output.write(output_str)
output.close()

# append to current
current = open('./current.txt', 'a')
current.write(',\r\n' + output_str)
current.close()

# print to console
print(output_str)