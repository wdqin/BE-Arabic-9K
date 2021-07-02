from dataset import training_detection_dataset 
from model import initialize_faster_rcnn_model
import torch
import torch.utils.data
import utils
from param import args
from engine import train_one_epoch, evaluate

def main():
	arabic_book_dataset = training_detection_dataset(args.evaluation_set,train=True)
	arabic_book_data_loader = torch.utils.data.DataLoader(arabic_book_dataset, batch_size=2, shuffle=True, num_workers=4, collate_fn=utils.collate_fn)
	model = initialize_faster_rcnn_model()

	device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')

	model.to(device)
	params = [p for p in model.parameters() if p.requires_grad]
	optimizer = torch.optim.SGD(params, lr=args.lr,
	                            momentum=args.momentum, weight_decay=args.weight_decay)
	lr_scheduler = torch.optim.lr_scheduler.StepLR(optimizer,
	                                               step_size=args.step_size,
	                                               gamma=args.gamma)
	num_epochs = args.num_epochs
	for epoch in range(num_epochs):
	    train_one_epoch(model, optimizer, arabic_book_data_loader, device, epoch, print_freq=10)
	    lr_scheduler.step()
	    torch.save(model.state_dict(), "./testing_model")

if __name__ == "__main__":
    main()

