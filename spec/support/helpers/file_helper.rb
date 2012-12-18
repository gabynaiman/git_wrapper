require 'fileutils'

class FileHelper

  def initialize
    @temp_folders = []
  end

  def create_temp_folder
    folder_name = "#{temp_path}/#{timestamp}"
    @temp_folders << folder_name
    FileUtils.mkpath folder_name
    folder_name
  end

  def remove_temp_folders
    @temp_folders.each do |folder_name|
      FileUtils.rm_rf folder_name
    end
  end

  def create_temp_file(folder, content)
    file_name = "#{folder}/file #{timestamp}.txt"
    sleep(0.01)
    File.open(file_name, 'w') do |file|
      file.puts content
    end
    file_name
  end

  private

  def temp_path
    Pathname.new("#{File.dirname(__FILE__)}/../../tmp").expand_path.to_s
  end

  def timestamp
    (Time.now.to_f * 1000).to_i
  end

end