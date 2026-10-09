# ============================================================
# Project #1: Job Sequencing with Deadlines
# by: yasmin badwan-1230271  & israa alyazouro-1231612
# ============================================================

.data
    title1:                .asciiz "==================================================\n"
    title2:                .asciiz "     Job Sequencing with Deadlines Using\n"
    title3:                .asciiz "              MIPS Assembly\n"
    title4:                .asciiz "--------------------------------------------------\n"
    title5:                .asciiz "        Developed by Yasmeen & Israa\n"
    title6:                .asciiz "==================================================\n\n"

    prompt_filename:       .asciiz "Please enter the name of file or path: "
    msg_input_file:        .asciiz "Input File: "
    msg_open_success:      .asciiz "\nFile opened successfully\n"
    msg_parse_success:     .asciiz "Jobs parsed successfully\n"
    msg_validation_done:   .asciiz "Validation completed\n"
    

    msg_file_error:        .asciiz "Error: Cannot open file. Please try again.\n"
    msg_invalid_data:      .asciiz "Error: Invalid data (deadline and profit must be > 0).\n"
    msg_too_many_jobs:     .asciiz "Error: Too many jobs (max 10 allowed).\n"

    msg_parse_header:      .asciiz "\n---------------- Parsed Jobs ----------------\n\n"
    msg_job_prefix:        .asciiz "J"
    msg_deadline_lbl:      .asciiz "    Deadline: "
    msg_profit_lbl:        .asciiz "    Profit: "
    msg_parse_done:        .asciiz "\n------------------------------------------------\n\n"

    newline:               .asciiz "\n"

    msgSequence:           .asciiz "\n=============== Best Job Sequence ===============\n\n"
    msgSlot:               .asciiz "Time Slot "
    msgColon:              .asciiz " : J"
    msgWithProfit:         .asciiz "      Profit : "

    msgProfit:             .asciiz "\n=================================================\nMaximum Total Profit = "
    msgProfit2:            .asciiz "\n=================================================\n"

    msgNotSelected:        .asciiz "\n--------------- Jobs Not Selected ---------------\n\n"
    msgNoNotSelected:      .asciiz "All jobs were selected.\n"

    filename:              .space  64
    file_buffer:           .space  512

    .align 2
    job_ids:               .space  40
    job_deadlines:         .space  40
    job_profits:           .space  40
    schedule:              .space  40
    selected_flags:        .space  40

    .align 2
    job_count:             .word   0

.text
.globl main

main:

# ============================================================
# Print Program Title
# ============================================================

    li $v0, 4
    la $a0, title1
    syscall

    li $v0, 4
    la $a0, title2
    syscall

    li $v0, 4
    la $a0, title3
    syscall

    li $v0, 4
    la $a0, title4
    syscall

    li $v0, 4
    la $a0, title5
    syscall

    li $v0, 4
    la $a0, title6
    syscall

# ============================================================
# File name input
# ============================================================

    li   $v0, 4
    la   $a0, prompt_filename
    syscall

    li   $v0, 8
    la   $a0, filename
    li   $a1, 64
    syscall
# Remove ENTER/newline from filename

    la   $t0, filename

remove_newline:
    lb   $t1, 0($t0)
    beqz $t1, done_newline

    li   $t2, 10        # \n
    beq  $t1, $t2, found_newline

    li   $t2, 13        # \r
    beq  $t1, $t2, found_newline

    addi $t0, $t0, 1
    j    remove_newline

found_newline:
    sb   $zero, 0($t0)

done_newline:

# Print input file name

    li $v0, 4
    la $a0, msg_input_file
    syscall

    li $v0, 4
    la $a0, filename
    syscall

    li $v0, 4
    la $a0, newline
    syscall

# ============================================================
# Open file
# ============================================================

    li   $v0, 13
    la   $a0, filename
    li   $a1, 0
    li   $a2, 0
    syscall

    move $s0, $v0

    bltz $s0, file_error

# ============================================================
# Read file
# ============================================================

    li   $v0, 14
    move $a0, $s0
    la   $a1, file_buffer
    li   $a2, 512
    syscall

# ============================================================
# Close file
# ============================================================

    li   $v0, 16
    move $a0, $s0
    syscall

    li   $v0, 4
    la   $a0, msg_open_success
    syscall

# ============================================================
# PARSING
# ============================================================

    la   $t0, file_buffer
    la   $t1, job_ids
    la   $t2, job_deadlines
    la   $t3, job_profits
    li   $t4, 0

parse_loop:
    li   $t5, 11
    bge  $t4, $t5, too_many_jobs

    lb   $t5, 0($t0)
    beqz $t5, parse_done

    li   $t6, 10
    beq  $t5, $t6, skip_char

    li   $t6, 13
    beq  $t5, $t6, skip_char

    li   $t6, 32
    beq  $t5, $t6, skip_char

    li   $t6, 74
    bne  $t5, $t6, skip_char
    
# Read Job ID after J
    addi $t0, $t0, 1       
    li   $t5, 0             

read_job_id:
    lb   $t6, 0($t0)
    blt  $t6, 48, job_id_done
    bgt  $t6, 57, job_id_done

    sub  $t6, $t6, 48
    mul  $t5, $t5, 10
    add  $t5, $t5, $t6

    addi $t0, $t0, 1
    j    read_job_id

job_id_done:
    sw   $t5, 0($t1)
    addi $t1, $t1, 4
# Skip space
addi $t0, $t0, 1

# Read deadline

    lb   $t5, 0($t0)
    addi $t0, $t0, 1
    sub  $t5, $t5, 48
    sw   $t5, 0($t2)
    addi $t2, $t2, 4

# Skip space

    addi $t0, $t0, 1

# Read profit

    li   $t5, 0

parse_profit:
    lb   $t6, 0($t0)
    blt  $t6, 48, profit_done
    bgt  $t6, 57, profit_done

    sub  $t6, $t6, 48
    mul  $t5, $t5, 10
    add  $t5, $t5, $t6

    addi $t0, $t0, 1
    j    parse_profit

profit_done:
    sw   $t5, 0($t3)
    addi $t3, $t3, 4

    addi $t4, $t4, 1
    j    parse_loop

skip_char:
    addi $t0, $t0, 1
    j    parse_loop

parse_done:
    sw   $t4, job_count

    li   $v0, 4
    la   $a0, msg_parse_success
    syscall

# ============================================================
# Print parsed jobs
# ============================================================

    li   $v0, 4
    la   $a0, msg_parse_header
    syscall

    li   $s1, 0
    lw   $s2, job_count

print_parsed_loop:
    bge  $s1, $s2, print_done

    li   $v0, 4
    la   $a0, msg_job_prefix
    syscall

    la   $t0, job_ids
    mul  $t1, $s1, 4
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_deadline_lbl
    syscall

    la   $t0, job_deadlines
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_profit_lbl
    syscall

    la   $t0, job_profits
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    addi $s1, $s1, 1
    j    print_parsed_loop

print_done:
    li   $v0, 4
    la   $a0, msg_parse_done
    syscall

# ============================================================
# VALIDATION
# ============================================================

    li   $t4, 0
    lw   $t8, job_count

validate_loop:
    bge  $t4, $t8, validation_ok

    la   $t0, job_deadlines
    mul  $t1, $t4, 4
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)

    la   $t0, job_profits
    add  $t0, $t0, $t1
    lw   $t3, 0($t0)

    blez $t2, invalid_data
    blez $t3, invalid_data

    addi $t4, $t4, 1
    j    validate_loop

validation_ok:
    li $v0, 4
    la $a0, msg_validation_done
    syscall

# ============================================================
# Sort arrays based on profit from highest to lowest
# ============================================================

    lw   $s0, job_count
    li   $t0, 0

outer_loop:
    addi $t2, $s0, -1
    bge  $t0, $t2, end_sort

    addi $t1, $t0, 1

inner_loop:
    bge  $t1, $s0, next_i

    sll  $t3, $t0, 2
    sll  $t4, $t1, 2

    lw   $t5, job_profits($t3)
    lw   $t6, job_profits($t4)

    ble  $t6, $t5, no_swap

    sw   $t6, job_profits($t3)
    sw   $t5, job_profits($t4)

    lw   $t5, job_deadlines($t3)
    lw   $t6, job_deadlines($t4)
    sw   $t6, job_deadlines($t3)
    sw   $t5, job_deadlines($t4)

    lw   $t5, job_ids($t3)
    lw   $t6, job_ids($t4)
    sw   $t6, job_ids($t3)
    sw   $t5, job_ids($t4)

no_swap:
    addi $t1, $t1, 1
    j inner_loop

next_i:
    addi $t0, $t0, 1
    j outer_loop

end_sort:

# ============================================================
# Find the maximum deadline value in the deadlines array
# ============================================================

    lw   $s1, job_deadlines
    li   $t0, 1

find_max_loop:
    bge  $t0, $s0, end_find_max

    sll  $t1, $t0, 2
    lw   $t2, job_deadlines($t1)

    ble  $t2, $s1, not_bigger

    move $s1, $t2

not_bigger:
    addi $t0, $t0, 1
    j find_max_loop

end_find_max:

# ============================================================
# initialize all schedule slots with 0
# ============================================================

    li   $t0, 0

init_schedule:
    bge  $t0, $s1, end_init

    sll  $t1, $t0, 2
    sw   $zero, schedule($t1)

    addi $t0, $t0, 1
    j init_schedule

end_init:

# ============================================================
# initialize selected_flags with 0
# 0 means not selected, 1 means selected
# ============================================================

    li   $t0, 0

init_flags:
    bge  $t0, $s0, end_flags

    sll  $t1, $t0, 2
    sw   $zero, selected_flags($t1)

    addi $t0, $t0, 1
    j init_flags

end_flags:

# ============================================================
# totalProfit = 0
# ============================================================

    li $s2, 0

# ============================================================
# Schedule jobs
# ============================================================

    li $t0, 0

job_loop:
    bge  $t0, $s0, end_jobs

    sll  $t1, $t0, 2

    lw   $t2, job_deadlines($t1)
    addi $t3, $t2, -1

slot_loop:
    blt  $t3, $zero, next_job

    sll  $t4, $t3, 2

    lw   $t5, schedule($t4)

    bne  $t5, $zero, previous_slot

    lw   $t6, job_ids($t1)
    sw   $t6, schedule($t4)

    li   $t8, 1
    sw   $t8, selected_flags($t1)

    lw   $t7, job_profits($t1)
    add  $s2, $s2, $t7

    j next_job

previous_slot:
    addi $t3, $t3, -1
    j slot_loop

next_job:
    addi $t0, $t0, 1
    j job_loop

end_jobs:

# ============================================================
# Print selected job sequence
# ============================================================

    li $v0, 4
    la $a0, msgSequence
    syscall

    li $t0, 0

print_schedule_loop:
    bge  $t0, $s1, print_profit

    sll  $t1, $t0, 2

    lw   $t2, schedule($t1)

    beq  $t2, $zero, skip_print

    li $v0, 4
    la $a0, msgSlot
    syscall

    addi $a0, $t0, 1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msgColon
    syscall

    move $a0, $t2
    li $v0, 1
    syscall

# Find profit of this selected job

    li $t3, 0

find_profit_loop:
    bge $t3, $s0, print_selected_newline

    sll $t4, $t3, 2
    lw  $t5, job_ids($t4)

    bne $t5, $t2, next_profit_search

    li $v0, 4
    la $a0, msgWithProfit
    syscall

    lw $a0, job_profits($t4)
    li $v0, 1
    syscall

    j print_selected_newline

next_profit_search:
    addi $t3, $t3, 1
    j find_profit_loop

print_selected_newline:
    li $v0, 4
    la $a0, newline
    syscall

skip_print:
    addi $t0, $t0, 1
    j print_schedule_loop

# ============================================================
# Print total profit
# ============================================================

print_profit:

    li $v0, 4
    la $a0, msgProfit
    syscall

    move $a0, $s2
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msgProfit2
    syscall

# ============================================================
# Print jobs not selected
# ============================================================

    li $v0, 4
    la $a0, msgNotSelected
    syscall

    li $t0, 0
    li $s3, 0

print_not_selected_loop:
    bge $t0, $s0, finish_not_selected

    sll $t1, $t0, 2
    lw  $t2, selected_flags($t1)

    bne $t2, $zero, skip_not_selected

    li $v0, 4
    la $a0, msg_job_prefix
    syscall

    lw $a0, job_ids($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msgWithProfit
    syscall

    lw $a0, job_profits($t1)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $s3, $s3, 1

skip_not_selected:
    addi $t0, $t0, 1
    j print_not_selected_loop

finish_not_selected:
    bne $s3, $zero, end_output

    li $v0, 4
    la $a0, msgNoNotSelected
    syscall

end_output:
    j exit_program

# ============================================================
# Error handling
# ============================================================

file_error:
    li   $v0, 4
    la   $a0, msg_file_error
    syscall
    j    exit_program

invalid_data:
    li   $v0, 4
    la   $a0, msg_invalid_data
    syscall
    j    exit_program

too_many_jobs:
    li   $v0, 4
    la   $a0, msg_too_many_jobs
    syscall
    j    exit_program

exit_program:
    li   $v0, 10
    syscall
