const fs = require('fs')
const path = require('path')
const contra = require('contra')
const request = require('request')
const glob = require('glob')

const cwd = process.cwd()
const userPath = process.argv[2]
const directory = path.resolve(cwd, userPath)
const pattern = path.join(directory, '*.png')
const imagesToUpload = glob.sync(pattern)

const slidesManifest = path.resolve(directory, './slides')
const slideRecords = require(slidesManifest)

const url = 'https://ponyfoo.com/api/images'

let images = []

uploadImageBatch(uploadFinished)

function uploadImageBatch(done) {
  const batch = imagesToUpload.splice(0, 4)

  if (batch.length === 0) {
    done(null)
    return
  }

  const uploads = batch.map(file => fs.createReadStream(file))
  const formData = { uploads }

  const options = {
    url,
    formData,
    json: true
  }

  request.put(options, (...rest) => uploadedBatch(done, ...rest))
}

function uploadedBatch(done, err, res, body) {
  if (err) {
    done(err)
    return
  }

  const batch = body.results.map(result => result.href)
  images = images.concat(batch)
  uploadImageBatch(done)
}

function uploadFinished(err) {
  if (err) {
    close(err)
    return
  }

  const slides = slideRecords.map((slide, i) => ({
    ...slide,
    image: images[i]
  }))

  fs.writeFileSync(slidesManifest, JSON.stringify(slides, null, 2) + '\n')

  printMarkdown(slides)
}

function printMarkdown(slides) {
  const references = slides
    .map((slide, i) =>
      `
[slide-${ i }]: ${ slide.image }`
    )
    .join('')

  const markdown = slides
    .map((slide, i) => {
      const pad = i === 0
        ? ''
        :
`::: .mde-pad-15
:::

`

      return
`${ pad }::: .mde-inline.mde-33
![][slide-${ i }]
:::

::: .mde-inline.mde-66
${ slide.notes }
:::

`
    })
    .join('')

  console.log(markdown)
  close(null)
}

function close(err) {
  if (err) {
    console.error(err)
    process.exit(1)
    return
  }

  process.exit(0)
}
