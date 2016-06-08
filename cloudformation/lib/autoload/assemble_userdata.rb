
# Take in the contents of all users data scripts, compile them into one string, and add useful comments along the way
def assemble_userdata
  userdata_dir = "#{File.dirname(File.expand_path($PROGRAM_NAME))}/userdata"
  script = "#!/bin/bash\n\n"
  Dir.glob("#{userdata_dir}/*.sh") do |sh_file|
    script << "\n# START #{File.basename(sh_file)}\n"
    script << File.read(sh_file)
    script << "\n# END #{File.basename(sh_file)}\n"
    script << "\n"
  end

  script
end
