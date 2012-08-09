// VARIABLES
History        = window.History,
document       = window.document,
text_title     = document.getElementById('text-title'),
text_content   = document.getElementById('text-content'),
saveInterval   = 1000,
draftsItems    = $('#drafts ul').data('items'),
publishedItems = $('#published ul').data('items'),
col_height     = 0,
showdown       = new Showdown.converter(),
lineHeight     = $('#line-height').height(),
previewHeight  = 0,
hideBarTimeout = null,
scrollTimeout  = null,
prevVal        = null;

// Keys
var key = {
  shift: false,
  cmd: false
};

// Elements
var el = fn.getjQueryElements({
  section   : '.split-section',
  published : '#published',
  drafts    : '#drafts',
  admin     : '#admin',
  editor    : '#post-editor',
  title     : '#post_title',
  content   : '#post_content',
  slug      : '#post_slug',
  url       : '#post_url',
  draft     : '#post_draft',
  page_input     : '#post_page',
  save      : '#save-button',
  form      : '#new_post,.edit_post',
  bar       : '#bar',
  curCol    : '#drafts',
  curColUl  : '#drafts ul',
  curItem   : '.col li:first',
  blog      : '#blog-button',
  publish   : '#publish-button',
  page      : '#page-button',
  preview   : '#post-preview'
});

// Editor state variables
var state = {
  post         : post_data,
  preview      : false,
  changed      : false,
  editing      : false,
  beganEditing : false,
  barHidden    : false,
  barPinned    : false,
  saving       : false,
  lastKey      : 0,
  lines        : 0,
  colIndex     : 0,
  itemIndex    : [0, 0]
};

// Allows for auto expanding textareas
function makeExpandingArea(container) {
  if (container == null){
    return;
  } 
  var area = container.querySelector('textarea'),
      span = container.querySelector('span');

 if (area.addEventListener) {
   area.addEventListener('input', function makeExpandingAreaCallback() {
     span.textContent = area.value;
   }, false);
   span.textContent = area.value;
 } else if (area.attachEvent) {
   // IE8 compatibility
   area.attachEvent('onpropertychange', function makeExpandingAreaCallback() {
     span.innerText = area.value;
   });
   span.innerText = area.value;
 }

 // Enable extra CSS
 container.className += ' active';
}

function makeExpandingAreas() {
  //makeExpandingArea(text_title);
  makeExpandingArea(text_content);
}

function showOnly(context,selectors) {
  $(context).addClass('hidden').filter(selectors).removeClass('hidden');
}

// Set post content height and column height
function setHeights() {
  var content_height = Math.max($(window).height() - el.title.height()-40,100);
  col_height = $(window).height()-125;
  $('.col ul').css('height', col_height);
  el.content.css('min-height', content_height);
  $('#content-fieldset').css('height', content_height);
  return col_height;
}

// Highlight an item in the column
function selectItem(object, items) {
  fn.log(object);
  el.curItem.removeClass('selected');
  el.curItem = object.addClass('selected');
  return el.curItem.index();
}

// Saves the post
function savePost(callback) {
  state.saving = true;
  state.changed = false;
  el.save.addClass('saving');
  fn.log('Saving',el.draft);

  // POST
  $.ajax({
    type: 'POST',
    url: el.form.attr('action'),
    data: el.form.serialize(),
    dataType: 'text',
    success: function savingSuccess(data) {
      var data = JSON.parse(data),
          li   = $('#post-'+data.id),
          list = (data.draft == 'true') ? $('#drafts ul') : $('#published ul');

      // Update state
      state.saving = false;

      // Update publish button
      el.save.removeClass('saving dirty').addClass('saved');
      setTimeout(function(){el.save.removeClass('saved')},500);

      // If we just finished creating a new post
      if (!state.post) {
        setFormAction('/edit/'+data.id);
        setFormMethod('put');
        pushState('/edit/'+data.id);
      }

      // Update cache and post data
      setCache(data.id, data);
      state.post = data;

      // Update form
      updateMetaInfo();

      // If item exists move to top, else add to top
      if (li.length) li.prependTo(list);
      else {
        $('#drafts ul').prepend('<li id="post-'+state.post.id+'"><a href="">'+el.title.val()+'</a></li>');
      }

      fn.log('Saved',data.id,data);
      if (callback) callback.call(this, data);
    },
    error: function (xmlHttpRequest, textStatus, errorThrown) {
      if (xmlHttpRequest.readyState == 0 || xmlHttpRequest.status == 0)
        return;  // it's not really an error
      else
        alert('Could not save.  Please backup your post!');
    }
  });
}

// Counts the number of characters in the meta-description
function countChar(val){
     var len = val.value.length;
     var description_counter = document.getElementById('description_counter')
     var remaining = (156 - len);
     description_counter.innerText= remaining;
};


// Get cache
function getCache(id) {
  var string = localStorage.getItem(id);
  return JSON.parse(string);
}

// Set cache
function setCache(id, data) {
  localStorage.setItem(id,JSON.stringify(data));
}

// Load it up
function loadCache(id, callback) {
  var cache = getCache(id);
  if (cache) {
    callback.call(this, cache);
  } else {
    $.getJSON('/get/'+id, function loadCacheCallback(data) {
      setCache(id, data);
      callback.call(this, data);
    });
  }
}

// Enter editor, val can be true, false, or the ID
//   true = editing a new post
//   false = exit editor
//   id = start editing id
function setEditing(val, callback) {
  fn.log('Set editing', val);
  if (val !== false) {
    // Update UI
    el.admin.addClass('editing');
    el.bar.removeClass('hidden');
    state.editing = true;
    showBar(true);

    // If true, start editing a new post
    if (val === true) {
      pushState('/new');
      setFormAction('/posts');
      setFormMethod('post');
    }
    // Editing post id = val
    else {
      loadCache(val, function setEditingLoadCache(data) {
        fn.log('got data', data);
        // Set state variables
        state.post = data;

        // Set form attributes
        el.content.val(state.post.content);
        updateMetaInfo();

        // Refresh form
        makeExpandingAreas();
        scrollToPosition();

        // Update url and form
        var url = '/edit/'+state.post.id;
        setFormAction(url);
        setFormMethod('put');
        pushState(url+window.location.hash);

        // Update link to post
        el.blog.attr('href',window.location.protocol+'//'+window.location.host+'/'+state.post.slug).attr('target','_blank');

        // Callbacks
        if (callback) callback.call(this, data);
      });
    }
  }
  else {
    // Save before closing
    if (state.changed) savePost();

    // Update state
    state.editing = false;
    state.beganEditing = false;

    // Clear form
    el.title.val('').focus();
    el.content.val('');
    makeExpandingAreas();
    setFormMethod('post');

    // Update UI
    el.blog.attr('href','/').removeAttr('target');
    el.admin.removeClass('preview editing');
    showBar(false);

    // Update selection
    selectItem($('#drafts li:first'));

    // Update URL
    pushState('/admin');
  }
}

function updateMetaInfo() {
  el.slug.val(state.post.slug);
  el.url.val(state.post.url);
  setDraft(state.post.draft);
  setPage(state.post.page);
}

function pushState(url) {
  History.pushState(state, url.split('/')[1], url);
}

// Set form action
function setFormAction(url) {
  el.form.attr('action',url);
}

// Set form method
function setFormMethod(type) {
  var put = $('form div:first input[value="put"]');
  if (type == 'put' && !put.length) $('form div:first').append('<input name="_method" type="hidden" value="put">');
  else if (type != 'put') put.remove();
}

// Either uses cache or loads post
function editSelectedItem(callback) {
  var id = el.curItem.attr('id').split('-')[1];
  // If they click on "New Draft..."
  if (id == 0) {
    var edit = true;
  } else {
    el.title.val(el.curItem.find('a').html());
    var edit = id;
  }
  setEditing(edit, function editSelectedItemCallback() {
    if (callback) callback.call();
  });
}

function setDraft(draft) {
  setDraftInput(draft);
  updateDraftButton(draft);
}

function setDraftInput(draft) {
  fn.log(draft);
  state.post.draft = draft
  el.draft.attr('value',(draft ? 1 : 0));
  if (draft){
    el.draft.attr('checked', 'checked');
  } else {
    el.draft.removeAttr('checked')
  }
  updateDraftButton(draft);
}

function updateDraftButton(draft) {
  fn.log(draft);
  if (draft) el.publish.html('Draft').addClass('icon-edit').removeClass('icon-check');
  else       el.publish.html('Published').removeClass('icon-edit').addClass('icon-check');
}


function setPage(page) {
fn.log( page);
  setPageInput(page);
  updatePageButton(page);
}

function setPageInput(page) {
  fn.log(page);
  state.post.page = page
  el.page_input.attr('value',(page ? 1 : 0));
  if (page){
    el.page_input.attr('checked', 'checked');
  } else {
    el.page_input.removeAttr('checked')
  }
  updatePageButton(page);
}

function updatePageButton(page) {
  fn.log(page);
  if (page) el.page.html('Static Page').addClass('icon-file').removeClass('icon-comment-alt');
  else       el.page.html('Blog Post').removeClass('icon-file').addClass('icon-comment-alt');
}





// Preview
function updatePreviewPosition() {
  if (state.preview) {
    var textareaOffset = el.content.offset().top,
        lineOffset     = parseInt((-textareaOffset)/lineHeight,10),
        percentDown    = lineOffset / state.lines,
        previewOffset  = previewHeight * percentDown;

    el.preview.scrollTop(previewOffset);
  }
}

// Markdown preview
function updatePreview() {
  var title = el.title.val().split("\n").join('<br />');
  $('#post-preview .inner').html('<h1>'+(title ? title : 'No Title')+'</h1>'+showdown.makeHtml(el.content.val()));
  state.lines   = el.content.height()/lineHeight;
  previewHeight = $('#post-preview .inner').height();
}

function togglePreview() {
  if (state.preview) hidePreview();
  else showPreview();
}

function hidePreview() {
  pushState('/edit');
  pushState('/edit/'+state.post.id);
  el.admin.removeClass('preview');
  $('#preview-button').removeClass('icon-eye-close').addClass('icon-eye-open');
  state.preview = false;
}

function showPreview() {
  updatePreview();
  window.location.hash = 'preview';
  el.admin.addClass('preview');
  makeExpandingAreas();
  $('#preview-button').removeClass('icon-eye-open').addClass('icon-eye-close');
  state.preview = true;
}

function toggleBar() {
  state.barPinned = !state.barPinned;
  $.cookie('barPinned',state.barPinned);
  if (state.barPinned) showBar(true);
  else showBar(false);
}

function showBar(yes) {
  state.barHidden = !yes;
  if (yes) {
    clearTimeout(hideBarTimeout);
    el.bar.removeClass('hidden');
  }
  else if (!state.barPinned && !el.bar.is(':hover')) {
    el.bar.addClass('hidden');
  }
}

function delayedHideBar(time) {
  clearTimeout(hideBarTimeout);
  hideBarTimeout = setTimeout(function(){showBar(false)},(time ? time : 1000));
}

function savePosition() {
  clearTimeout(scrollTimeout);
  if (state.editing) {
    scrollTimeout = setTimeout(function() {
      $.cookie('position-'+state.post.id,el.editor.scrollTop());
    },1000);
  }
}

// Scroll to bottom of content and select the end
function scrollToPosition() {
  var cookie = $.cookie('position-'+state.post.id);
  fn.log('Scroll to position',cookie);
  if (cookie) el.editor.scrollTop(cookie);
  else {
    // Scroll to bottom
    el.content.focus().putCursorAtEnd();
    $('#post-editor').scrollTop(el.content.height());
  }
}

function heartbeatLogger() {
  fn.log('State:',state,'Elements',el);
}
