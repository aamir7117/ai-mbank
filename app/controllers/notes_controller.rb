class NotesController < ApplicationController
  def index
    @notes = Note.all.order(created_at: :desc)
  end

  def show
    @note = Note.find(params[:id])
  end

  def new
    @note = Note.new
    @reminder = Reminder.new
  end

  def voice_to_text
      client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
      puts 'building tmp file and getting mp3 data from file'
      tmpfile = Tempfile.new(['tmp', '.mp3'], binmode: true)
      content = params["files"].tempfile.read
      tmpfile.write(content)
      tmpfile.rewind
      puts 'transcribing using Whisper API..'
      response = client.translate(parameters: { model: "whisper-1", file: tmpfile })
      tmpfile.close
      tmpfile.unlink
      puts 'api done'

      # save note
      @note = Note.new
      @note.text = response["text"]
      @note.user = current_user
      @note.save
      puts "#{@note.id} transcribed! #{@note.text[0..100]}..."
      respond_to do |format|
        format.json { render json: @note }
      end
  end

    def generate_imgs
      @note = Note.find(params[:id])
      payload = @note.text.split('.')
      client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
      image_urls = []
      @note.ai_images.purge_later # Delete images from cloudinary and activerecord
      payload.each do |sentence|
        response = client.images.generate(parameters: { prompt: sentence, size: "256x256", n: 1 })
        remote_url = response["data"][0]["url"]
        @note.ai_images.attach(
          filename: "item.jpg",
          io: URI.parse(remote_url).open
        )
        image_urls.push(remote_url)
      end
      @note.save

      respond_to do |format|
        format.json { render json: @note.ai_images.map { |i| i.url } }
      end
    end

    def chatgpt
      client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
      @note = @note || Note.new
      puts 'Expanding descriptions using ChatGPT API..'
      prefix = 'describe in a highly detailed way and in less than 15 words an image with the idea,'
      content = "Remember to call back Mum"
      payload = "#{prefix} '#{content}'"
      response = client.chat(parameters: { model: "gpt-3.5-turbo", messages: [{ role: "user", content: payload }], temperature: 0.7 })
      # response = client.chat( parameters: { model: "text-davinci-002", messages: [{ role: "user", content: "Hello!"}], temperature: 0.7 })
    end

end
