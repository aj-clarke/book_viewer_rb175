require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  # File.read "public/template.html"
  # @contents = File.readlines("data/toc.txt") # => Extracted to `before`
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  # @contents = File.readlines("data/toc.txt") # => Extracted to `before`
  @title = "Chapter #{params[:number]}"
  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get "/search" do
  @results = search_each_chapter(params[:query])
  highlight_search_results(params[:query])

  erb :search
end

helpers do
  def in_paragraphs
    str = String.new
    @chapter.split("\n\n").each_with_index do |paragraph, paragraph_index|
      str << "<p id=paragraph_#{paragraph_index}>#{paragraph}</p>"
    end
    # LS SOLUTION
    # def in_paragraphs(text)
    #   text.split("\n\n").map do |paragraph|
    #     "<p>#{paragraph}</p>"
    #   end.join
    # end
    str
  end

  def highlight_search_results(query)
    text = query.to_s
    bolded = "<strong>#{query}</strong>"
    @results.each do |hash|
      hash[:paragraph_results].each do |sub_arr|
        sub_arr[0].gsub!(text, bolded)
      end
    end
  end
end

not_found do
  redirect "/"
end

def search_each_paragraph(contents, query)
  results = []
  contents.split("\n\n").each_with_index do |paragraph, paragraph_id|
    results << [paragraph, paragraph_id] if paragraph.include? query
  end
  results
end

def each_chapter
  @contents.each_with_index do |chapter_name, idx|
    chapter_num = idx + 1
    contents = File.read("data/chp#{chapter_num}.txt")
    yield chapter_num, chapter_name, contents
  end
end

def search_each_chapter(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |chapter_num, chapter_name, contents|
    if contents.include? query
      paragraph_results = search_each_paragraph(contents, query)
      results << { chapter_num: chapter_num, chapter_name: chapter_name,
                   paragraph_results: paragraph_results }
    end
  end

  results
end
