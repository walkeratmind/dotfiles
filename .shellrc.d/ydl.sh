

# youtube-dl
alias ydl-aac="youtube-dl --extract-audio --audio-format aac "
alias ydl-best="youtube-dl --extract-audio --audio-format best "
alias ydl-flac="youtube-dl --extract-audio --audio-format flac "
alias ydl-m4a="youtube-dl --extract-audio --audio-format m4a "
alias ydl-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias ydl-opus="youtube-dl --extract-audio --audio-format opus "
alias ydl-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias ydl-wav="youtube-dl --extract-audio --audio-format wav "
alias ytv-best="youtube-dl -f bestvideo+bestaudio "


function ydl {
    local list=$(youtube-dl --list-formats $1)

    echo $list | sed -n '/[0-9]x[0-9]/p'
    echo -n "video format (default=244, skip=0): "; read video
    if [[ "$video" == 0 ]]; then
        video=""
    else
        video="${video:-244}"
    fi

    echo $list | sed -n '/audio only/p'
    total=$(echo $list | sed -n '/audio only/p' | wc -l)
    # TODO: check 320 is in or not
    echo -n "audio format (default=320, skip=0): "; read audio
    if [[ "$audio" == 0 ]]; then
        audio=""
    else
        audio="${audio:-320}"
        if [[ "$video" != "" ]]; then
            audio="+$audio"
        fi
    fi

    echo youtube-dl --format "${video}${audio}" $1
    youtube-dl --format "${video}${audio}" $1
}
