cd ../app

mix deps.get

case "$1" in
    prepare)
        cd assets
        npm install
        cd ..
        exit 0
        ;;
    test)
      mix test
      exit 0
      ;;

    *)

iex -S mix phx.server
exit 0
;;
esac