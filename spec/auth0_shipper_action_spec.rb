describe Fastlane::Actions::Auth0ShipperAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The auth0_shipper plugin is working!")

      Fastlane::Actions::Auth0ShipperAction.run(nil)
    end
  end
end
