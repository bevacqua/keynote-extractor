-- import JSON script
tell application "Finder"
  set json_path to file "json.scpt" of folder of (path to me)
end
set json to load script (json_path as alias)

-- pull data from Keynote
tell application "Keynote"
  activate

  tell front document
    set outputFolderName to "keynote-" & name

    if outputFolderName ends with ".key" then
      set outputFolderName to text 1 thru -5 of outputFolderName
    end if

    set outputFolder to (path to desktop folder as string) & outputFolderName

    set titles to object text of default title item of every slide
    set notes to presenter notes of every slide
  end tell

  export front document to outputFolder as slide images
end tell

-- prepare JSON payload
set slides to "["

repeat with index from 1 to length of titles
  if not (item index of notes) = "" then
    if not index = 1 then
      set slides to slides & ", "
    end if

    set paddedIndex to index
    if index < 100 then
      set paddedIndex to "0" & paddedIndex
      if index < 10 then
        set paddedIndex to "0" & paddedIndex
      end if
    end if

    set slides to slides & "{" & return

    set slides to slides & "  \"title\": " & json's encode("Slide " & index) & "," & return
    set slides to slides & "  \"slide\": " & json's encode(outputFolderName & "." & paddedIndex & ".png") & "," & return
    set slides to slides & "  \"notes\": " & json's encode(item index of notes) & return

    set slides to slides & "}"
  end if
end repeat

set slides to slides & "]"

-- write JSON to disk
set slidesFile to outputFolder & ":slides.json"
set slidesRef to open for access file slidesFile with write permission
set eof of slidesRef to 0
write ((ASCII character 239) & (ASCII character 187) & (ASCII character 191)) to slidesRef
write slides as «class utf8» to slidesRef
close access slidesRef

-- prepare Markdown payload
set sections to ""
set anchors to return & return

repeat with index from 1 to length of titles
  if not (item index of notes) = "" then
    if not index = 1 then
      set sections to sections & return & return
    end if

    set paddedIndex to index
    if index < 100 then
      set paddedIndex to "0" & paddedIndex
      if index < 10 then
        set paddedIndex to "0" & paddedIndex
      end if
    end if

    set sections to sections & "# Slide " & index & return & return
    set sections to sections & "![][slide-" & index & "]" & return & return
    set sections to sections & item index of notes

    set anchors to anchors & "[slide-" & index & "]: " & outputFolderName & "." & paddedIndex & ".png" & return
  end if
end repeat

set readme to sections & anchors

-- write Markdown to disk
set readmeFile to outputFolder & ":readme.md"
set readmeRef to open for access file readmeFile with write permission
set eof of readmeRef to 0
write ((ASCII character 239) & (ASCII character 187) & (ASCII character 191)) to readmeRef
write readme as «class utf8» to readmeRef
close access readmeRef
