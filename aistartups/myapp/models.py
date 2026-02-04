from django.db import models
from django.contrib.auth.admin import User
# Create your models here.
class Students(models.Model):
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.CharField(max_length=10)
    place=models.CharField(max_length=100)
    pin=models.CharField(max_length=6)
    district=models.CharField(max_length=100)
    login=models.OneToOneField(User,on_delete=models.CASCADE)
    state=models.CharField(max_length=100)
    photo=models.ImageField(upload_to='studuser')

class Experts(models.Model):
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.CharField(max_length=10)
    place=models.CharField(max_length=100)
    post=models.CharField(max_length=100)
    pin=models.CharField(max_length=6)
    photo=models.ImageField(upload_to='verexpeuser')
    proof=models.ImageField(upload_to='expeproof')
    district=models.CharField(max_length=100)
    status=models.CharField(max_length=100)
    login=models.OneToOneField(User,on_delete=models.CASCADE)

class Viewstartup(models.Model):
    title=models.CharField(max_length=100)
    description=models.TextField(max_length=5000)
    technologies=models.CharField(max_length=400)
    date=models.DateField()

class Notifications(models.Model):
    date=models.DateField()
    title=models.CharField(max_length=100)
    notification=models.CharField(max_length=500)

class Feedback(models.Model):
    date=models.DateField()
    feedback = models.CharField(max_length=100)
    user=models.ForeignKey(Students, on_delete=models.CASCADE)

class Review_rating(models.Model):
    date=models.DateField()
    review=models.CharField(max_length=100)
    rating=models.CharField(max_length=100)
    user=models.ForeignKey(Students, on_delete=models.CASCADE)

class Complaints(models.Model):
    date=models.DateField()
    reply=models.CharField(max_length=1000)
    complaints=models.CharField(max_length=1000)
    user=models.ForeignKey(Students, on_delete=models.CASCADE)

class Doubt(models.Model):
    doubt=models.CharField(max_length=100)
    date=models.DateField()
    reply=models.CharField(max_length=100)
    user=models.ForeignKey(Students, on_delete=models.CASCADE)
    expert=models.ForeignKey(Experts, on_delete=models.CASCADE)
    status=models.CharField(max_length=100)

class Student_requests(models.Model):
    student=models.ForeignKey(Students,on_delete=models.CASCADE)
    expert=models.ForeignKey(Experts,on_delete=models.CASCADE)
    description=models.CharField(max_length=500)
    date = models.DateField()
    request_reply=models.CharField(max_length=100)
    status=models.CharField(max_length=10)

class Skills(models.Model):
    user = models.ForeignKey(Students, on_delete=models.CASCADE)
    academics= models.CharField(max_length=1000)
    tech_skills=models.CharField(max_length=1000)
    interests=models.CharField(max_length=1000)
    pref_industry=models.CharField(max_length=1000)
    investment_cap=models.CharField(max_length=500)

class Bookmark(models.Model):
    user = models.ForeignKey(Students, on_delete=models.CASCADE)
    idea = models.ForeignKey(Student_requests, on_delete=models.CASCADE)

