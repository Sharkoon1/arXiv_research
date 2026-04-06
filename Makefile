run:
	flutter run

test:
	flutter test

build:
	dart run build_runner build --delete-conflicting-outputs

get:
	flutter pub get

clean:
	flutter clean && flutter pub get
