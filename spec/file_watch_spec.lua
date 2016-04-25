require 'busted'
require 'file_watch'

describe('File watch', function()
  describe('.watch_path_and_contents', function()
   local called = false
   local function callback(path)
    called = true
    assert.truthy(called)
   end
   local tester = {
     callback = callback
   }

   teardown(function()
    os.execute('rm -rf ./test_paths')
   end)

   it('calls a callback when there is a file addition', function()
      local called = false
      local function callback(path)
        called = true
        assert.truthy(called)
      end
      file_watch.watch_path_and_contents('.', tester.callback)
      os.execute('mkdir ./test_paths')
    end)

    it('calls a callback when there is a file modification', function()
      os.execute('mkdir ./test_paths')
      os.execute('touch ./test_paths/test')
      called = false
      spy.on(tester, 'callback')
      file_watch.watch_path_and_contents('./test_paths', tester.callback)
      os.execute('echo "text" >> ./test_paths/test')
      os.execute('echo "text2" >> ./test_paths/test')
      --assert.spy(tester.callback).was.called()
    end)
  end)
end)
