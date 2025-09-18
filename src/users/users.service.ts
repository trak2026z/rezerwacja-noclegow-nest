import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<UserDocument> {
    const { email, username } = createUserDto;
    
    // sprawdzanie unikalności emaila
    const emailExists = await this.findByEmail(email);
    if (emailExists) {
      throw new ConflictException('Email is already taken');
    }
    
    // sprawdzanie unikalności username
    const usernameExists = await this.findByUsername(username);
    if (usernameExists) {
      throw new ConflictException('Username is already taken');
    }
    
    // tworzenie nowego użytkownika
    const createdUser = new this.userModel(createUserDto);
    return createdUser.save();
  }

  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email: email.toLowerCase() }).exec();
  }

  async findByUsername(username: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ username: username.toLowerCase() }).exec();
  }

  async findById(id: string): Promise<UserDocument> {
    const user = await this.userModel.findById(id).exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async isEmailTaken(email: string): Promise<boolean> {
    const user = await this.findByEmail(email);
    return !!user;
  }

  async isUsernameTaken(username: string): Promise<boolean> {
    const user = await this.findByUsername(username);
    return !!user;
  }

  async getPublicProfile(username: string) {
    const user = await this.findByUsername(username);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return { username: user.username, email: user.email };
  }
}
