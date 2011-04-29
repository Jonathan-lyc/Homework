struct node {
  int data;
  struct node *next;
};

struct node *head;
int count = 0;

void
ll_add(int i){
  struct node *n;
  n = (struct node *)malloc(sizeof(struct node));
  n->data = i;
  n->next = 0;
  if (head == 0) {
    head = n;
  } else {
    struct node *curr = head;
/*    printf(1, "i = %d", i);*/
    while(curr->next != 0) {
/*      printf(1, "next! i = %d", i);*/
      curr = curr->next;
    }
    curr->next = n;
/*    printf(1, "currnext = %d\n", curr->next);*/
	
  }
  count++;
}

void ll_print(){
  struct node *n;
  n = head;
  while(n != 0) {
    printf(1, "%d\n", n->data);
    n = n->next;
  }
}
void ll_coolj(){
  struct node *n;
  n = head;
  int i = 0;
  while(n != 0) {
    i += n->data;
    n = n->next;
  }
  printf(1, "total = %d\n", i);
}
void ll_count() {
  printf(1, "Count: %d\n", count); 
}
