from math import ceil
import sys

ALU_OPS = ['ADD', 'SUB', 'MUL', 'DIV', 'AND', 'OR', 'XOR', 'NOR', 'NAND']


def translate_register(reg):
    return f'{bin(int(reg[1:]))[2:]:0>2}'


def resolve_value(val, aliases):
    if val[0] == '$':
        try:
            return aliases[val]
        except:
            print(f'Unrecognized alias {val}')
            exit(1)
    return f'{bin(int(val, 16))[2:]:0>16}'


def format_mem_file(data, width):
    width = ceil(width/4)
    memory = ''
    for addr, val in data.items():
        memory = f'{memory}{hex(int(val, 2))[2:]:0>{width}}\n'
    return memory


def main(argv):
    if len(argv) < 1:
        print('Must provide a file to assemble!')
        exit(1)

    with open(argv[0]) as sourcefile:
        aliases = {}

        data = {}

        tokenized_instructions = []
        deps = {}
        instructions = []
        branches = {}

        # "Zeroth" pass
        # Tokenize instructions and find loop markers
        instruction_num = 0
        mode = ''
        for line in sourcefile:
            tokenized = line.split()
            if len(tokenized) == 0:
                continue
            if tokenized[0][0] == '#':
                mode = tokenized[0][1:]
                continue
            if mode == 'alias':
                if len(tokenized) < 2:
                    print('Must provide an alias name and value')
                    exit(1)
                if tokenized[0][0] != '$':
                    print('Aliases must start with `$`')
                    exit(1)
                try:
                    aliases[tokenized[0]
                            ] = f'{bin(int(tokenized[1], 16))[2:]:0>16}'
                except:
                    print(
                        f'Could not recognize {tokenized[1]} as a hex string')
                    exit(1)
            elif mode == 'data':
                if len(tokenized) < 2:
                    print('Must provide an address and value')
                    exit(1)
                adr = resolve_value(tokenized[0], aliases)
                val = resolve_value(tokenized[1], aliases)
                data[adr] = val
            elif mode == 'start':
                if line[0] == '.':
                    branches[line.strip()] = instruction_num
                    continue
                tokenized_instructions.append(tokenized)
                instruction_num += 1
            else:
                print('Provide a valid mode indicator (#alias, #data, #start)')
                exit(1)

        # First pass
        # Find dependencies
        last_read = {}
        last_write = {}
        for instruction_num, tokenized in enumerate(tokenized_instructions):
            reads = []
            writes = []
            if tokenized[0] in ['NOOP', 'JMP']:
                pass
            elif tokenized[0] == 'STORE':
                reads.append(tokenized[1])
                reads.append(tokenized[2])
            elif tokenized[0] == 'JNZ':
                reads.append(tokenized[1])
            elif tokenized[0] == 'JEZ':
                reads.append(tokenized[1])
            elif tokenized[0] == 'LOAD':
                writes.append(tokenized[1])
                reads.append(tokenized[2])
            elif tokenized[0] == 'LOADI':
                writes.append(tokenized[1])
            elif tokenized[0] in ALU_OPS:
                writes.append(tokenized[1])
                reads.append(tokenized[2])
                reads.append(tokenized[3])
            else:
                raise Exception('Invalid instruction encountered')
            _deps = []
            _antideps = []
            for reg in reads:
                if reg in last_write:
                    _deps.append(last_write[reg])
            for reg in writes:
                if reg in last_read:
                    _antideps.append(last_read[reg])
                if reg in last_write:
                    _antideps.append(last_write[reg])
            for reg in reads:
                last_read[reg] = instruction_num
            for reg in writes:
                last_write[reg] = instruction_num
            deps[instruction_num] = {'dep': _deps, 'antidep': _antideps}

        # Second pass
        # Rearragne instructions
        for instruction_num, tokenized in enumerate(tokenized_instructions):
            if tokenized[0] == 'LOAD':
                # If the next instruction doesn't reference the register we're changing, then all good
                # Otherwise, we can find one that doesn't and try to move it
                # Instructions can't move past a jump address or a jump instructions
                # LOAD and STORE instructions must maintain the same relative order
                inst_to_move = -1
                if ((instruction_num + 1) in deps) and (instruction_num in deps[instruction_num + 1]['dep']):
                    # Search backwards
                    temp_num = instruction_num - 1
                    dep_acc = deps[instruction_num]['dep'].copy()
                    antidep_acc = deps[instruction_num]['antidep'].copy()
                    while temp_num >= 0\
                            and temp_num not in branches.values()\
                            and tokenized_instructions[temp_num][0] not in ['JMP', 'JNZ', 'JEZ']\
                            and inst_to_move < 0:
                        if tokenized_instructions[temp_num][0] not in ['STORE', 'LOAD']\
                                and temp_num not in dep_acc\
                                and temp_num not in antidep_acc:
                            inst_to_move = temp_num
                        dep_acc.extend(deps[temp_num]['dep'])
                        antidep_acc.extend(deps[temp_num]['antidep'])
                        temp_num -= 1
                    # Search forwards (if no suitable instruction found yet)
                    passed_mem = len(tokenized_instructions) > instruction_num + 1\
                        and tokenized_instructions[instruction_num + 1][0] in ['LOAD', 'STORE']
                    temp_num = instruction_num + 2
                    while temp_num < len(tokenized_instructions)\
                            and temp_num not in branches.values()\
                            and tokenized_instructions[temp_num][0] not in ['JMP', 'JNZ', 'JEZ']\
                            and inst_to_move < 0:
                        if all([x < instruction_num for x in deps[temp_num]['dep']])\
                                and all([x < instruction_num for x in deps[temp_num]['antidep']]):
                            if not (passed_mem and tokenized_instructions[temp_num][0] in ['STORE', 'LOAD']):
                                inst_to_move = temp_num
                        if tokenized_instructions[temp_num][0] in ['STORE', 'LOAD']:
                            passed_mem = True
                        temp_num += 1
                    if inst_to_move == -1:
                        tokenized_instructions.insert(
                            instruction_num + 1, ['NOOP'])
                        for [branch, dest] in branches.items():
                            if dest > instruction_num:
                                print(branch, dest)
                                branches[branch] += 1
                    else:
                        moved_inst = tokenized_instructions.pop(inst_to_move)
                        if inst_to_move < instruction_num:
                            tokenized_instructions.insert(
                                instruction_num, moved_inst)
                        else:
                            tokenized_instructions.insert(
                                instruction_num + 1, moved_inst)
            elif tokenized[0] in ['JMP', 'JNZ', 'JEZ']:
                # No way around it -- we have to stall 2 cycles
                tokenized_instructions.insert(instruction_num + 1, ['NOOP'])
                tokenized_instructions.insert(instruction_num + 1, ['NOOP'])
                for [branch, dest] in branches.items():
                    if dest > instruction_num:
                        branches[branch] += 2

        # Third pass
        # Write machine code
        for tokenized in tokenized_instructions:
            instruction = ''
            if tokenized[0] == 'NOOP':
                instruction = ''
            elif tokenized[0] == 'JMP':
                opcode = '0001'
                if tokenized[1][0] != '.':
                    print('Jump instructions must target a valid destination')
                    exit(1)
                destination = bin(branches[tokenized[1]])[2:]
                instruction = f'{opcode}{destination:0>16}'
            elif tokenized[0] == 'STORE':
                opcode = '0010'
                source = translate_register(tokenized[1])
                destination = translate_register(tokenized[2])
                instruction = f'{opcode}{source}{destination}'
            elif tokenized[0] == 'JNZ':
                opcode = '0011'
                if tokenized[1][0] != '.':
                    print('Jump instructions must target a valid destination')
                    exit(1)
                source = translate_register(tokenized[1])
                destination = bin(branches[tokenized[2]])[2:]
                instruction = f'{opcode}{source}{destination:0>16}'
            elif tokenized[0] == 'JEZ':
                opcode = '0100'
                if tokenized[1][0] != '.':
                    print('Jump instructions must target a valid destination')
                    exit(1)
                source = translate_register(tokenized[1])
                destination = bin(branches[tokenized[2]])[2:]
                instruction = f'{opcode}{source}{destination:0>16}'
            elif tokenized[0] == 'LOAD':
                opcode = '0101'
                destination = translate_register(tokenized[1])
                source = translate_register(tokenized[2])
                instruction = f'{opcode}{destination}{source}'
            elif tokenized[0] == 'LOADI':
                opcode = '0110'
                destination = translate_register(tokenized[1])
                source = resolve_value(tokenized[2], aliases)
                instruction = f'{opcode}{destination}{source}'
            elif tokenized[0] in ALU_OPS:
                opcode = bin(ALU_OPS.index(tokenized[0]) + 7)[2:]
                destination = translate_register(tokenized[1])
                source_a = translate_register(tokenized[2])
                source_b = translate_register(tokenized[3])
                instruction = f'{opcode:0>4}{destination}{source_a}{source_b}'
            else:
                raise Exception('Invalid instruction encountered')
            instructions.append(f'{instruction:0<22}')

        datafile = format_mem_file(data, 16)
        instrfile = format_mem_file(
            {bin(addr)[2:]: inst for addr, inst in enumerate(instructions)}, 22)
        dmem = open('DMEM.mem', 'w+')
        dmem.write(datafile)
        dmem.close()
        imem = open('IMEM.mem', 'w+')
        imem.write(instrfile)
        imem.close()


if __name__ == '__main__':
    main(sys.argv[1:])
