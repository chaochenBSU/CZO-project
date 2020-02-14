set fileId [open stats4.txt r 0600]
# puts $fp
#set file_data [read $fp]
#puts $file_data
#set data [split $file_data "\n"]
#foreach line $data {
#puts $data
#}
 set a [gets $fileId]
puts $a
set b [gets $fileId]
puts $b
